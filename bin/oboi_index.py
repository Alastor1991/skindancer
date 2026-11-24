#!/usr/bin/env python3
"""Индекс обоев для поиска и миниатюры.

oboi-index [--dir DIR ...] [--out FILE] [--thumbs DIR] [--quiet]

Обходит папки обоев (по умолчанию папка картинок XDG), читает описания из
DIR/.oboi/<имя файла>.json, делает миниатюры в ~/.cache/oboi/thumbs и пишет
~/.cache/oboi/index.json. Индекс и миниатюры у каждой машины свои, в синхронизацию
не попадают. Описания лежат рядом с картинками, по файлу на картинку, поэтому
две машины не пишут один и тот же файл.
"""
import argparse, fcntl, hashlib, json, os, sys, tempfile, time

HOME = os.path.expanduser("~")
CACHE = os.environ.get("OBOI_CACHE") or os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.join(HOME, ".cache")), "oboi")
# избранное для папок, куда нельзя писать (системные обои, NFS только для чтения, /nix/store)
STATE_FAVS = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.join(HOME, ".local", "state")), "oboi", "favorites.json")
EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".avif", ".jxl"}
THUMB_H = 540


def config_dirs():
    """Папки обоев из $XDG_CONFIG_HOME/oboi/config.json: {"dirs": ["~/Pictures/Wallpapers", ...]}"""
    base = os.environ.get("XDG_CONFIG_HOME", os.path.join(HOME, ".config"))
    try:
        with open(os.path.join(base, "oboi", "config.json"), encoding="utf-8") as fh:
            return [os.path.expanduser(d) for d in json.load(fh).get("dirs", [])]
    except (OSError, ValueError):
        return []


SKIP_DIRS = {"screenshots", "скриншоты", "снимки экрана"}


def skip(name):
    """Что не считается обоями рабочего стола."""
    n = name.lower()
    return (n.startswith(".") or n.endswith(".part") or ".sync-conflict-" in n
            or os.path.splitext(n)[1] not in EXTS)


def scan(dirs):
    for d in dirs:
        d = os.path.expanduser(d)
        if not os.path.isdir(d):
            continue
        for root, subdirs, files in os.walk(d):
            # .oboi, .stversions, .stfolder; папки снимков экрана обоями не считаются
            subdirs[:] = [s for s in subdirs if not s.startswith(".") and s.lower() not in SKIP_DIRS]
            for f in sorted(files):
                if not skip(f):
                    yield root, f


def read_meta(root, name):
    p = os.path.join(root, ".oboi", name + ".json")
    try:
        with open(p, encoding="utf-8") as fh:
            m = json.load(fh)
    except (OSError, ValueError):
        return {}
    return m if isinstance(m, dict) else {}       # чужой или битый сайдкар не должен ронять индекс


def state_favs():
    try:
        with open(STATE_FAVS, encoding="utf-8") as fh:
            d = json.load(fh)
        return d if isinstance(d, dict) else {}
    except (OSError, ValueError):
        return {}


def text(v):
    return v if isinstance(v, str) else ""


def words(v):
    return [x for x in v if isinstance(x, str)] if isinstance(v, list) else []


def make_thumb(src, dst):
    from PIL import Image, ImageOps
    # Обои бывают огромными (панорамы 20k px). Pillow бросает ошибку на удвоенном пределе:
    # с 200 Мпикс файлы больше 400 Мпикс пропускаются, а не съедают память.
    Image.MAX_IMAGE_PIXELS = 200_000_000
    with Image.open(src) as im:
        w, h = im.size
        # Ориентация EXIF бывает у фото (JPEG, WebP). У PNG getexif() декодирует файл целиком
        # в поисках EXIF в конце, и индекс шёл вчетверо дольше, поэтому PNG не спрашиваем.
        orient = im.getexif().get(0x0112, 1) if im.format in ("JPEG", "MPO", "WEBP", "TIFF") else 1
        turned = orient in (5, 6, 7, 8)                      # снято боком
        if turned:
            w, h = h, w
        # draft до разворота: JPEG декодируется сразу уменьшенным, а не в полный размер
        im.draft("RGB", (THUMB_H * 4, THUMB_H * 4) if turned else (THUMB_H * 2, THUMB_H))
        if orient != 1:
            im = ImageOps.exif_transpose(im)
        im = im.convert("RGB")
        im.thumbnail((THUMB_H * 4, THUMB_H))
        tmp = dst + ".tmp"
        im.save(tmp, "JPEG", quality=84, optimize=True)
        os.replace(tmp, dst)
        return w, h


def hue_of(thumb):
    """Главный оттенок: 12 корзин по 30° или -1 (серый). Почти чёрное и почти белое не считается."""
    import colorsys
    from PIL import Image
    with Image.open(thumb) as im:
        small = im.convert("RGB").resize((64, 36))
        # getdata уходит в Pillow 14, get_flattened_data появилась ей на замену
        px = list(small.get_flattened_data() if hasattr(small, "get_flattened_data") else small.getdata())
    bins, chroma = [0] * 12, 0
    for r, g, b in px:
        h, l, s_ = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        if l < 0.06 or l > 0.94 or s_ < 0.18:
            continue
        bins[int(h * 12) % 12] += 1; chroma += 1
    if chroma < len(px) * 0.05:
        return -1, 0.0
    best = max(range(12), key=lambda i: bins[i])
    return best, round(bins[best] / len(px), 3)


def size_of(src):
    from PIL import Image
    Image.MAX_IMAGE_PIXELS = 200_000_000
    with Image.open(src) as im:
        return im.size


def write_json(path, data):
    """Атомарная запись с уникальным временным файлом: два процесса не делят один .tmp."""
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path), prefix=".oboi-", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(data, fh, ensure_ascii=False, indent=1)
        os.replace(tmp, path)
    except BaseException:
        if os.path.exists(tmp):
            os.remove(tmp)
        raise


def stamp(p):
    try:
        st = os.stat(p)
        return (st.st_mtime_ns, st.st_size, st.st_ino)
    except OSError:
        return None


def set_favorite(path, mode):
    path = os.path.abspath(os.path.expanduser(path))
    root, name = os.path.split(path)
    md = os.path.join(root, ".oboi")
    try:
        if os.path.islink(md):              # ссылка увела бы запись за пределы папки обоев
            raise PermissionError(md)
        os.makedirs(md, exist_ok=True)
        if not os.access(md, os.W_OK):
            raise PermissionError(md)
    except OSError:
        # в папку не записать: избранное хранится у пользователя, а не рядом с картинкой
        f = state_favs()
        cur = f.get(path, bool(read_meta(root, name).get("favorite")))
        f[path] = (not cur) if mode == "toggle" else (mode == "on")
        os.makedirs(os.path.dirname(STATE_FAVS), exist_ok=True)
        write_json(STATE_FAVS, f)
        return f[path]
    sp = os.path.join(md, name + ".json")
    # Syncthing может подменить описание, пока мы его правим: перед заменой сверяем, что файл тот же,
    # иначе перечитываем и правим заново, чтобы не вернуть старые теги поверх свежих
    for _ in range(5):
        before = stamp(sp)
        m = {"file": name}
        if before is not None:
            try:
                with open(sp, encoding="utf-8") as fh:
                    m = json.load(fh)
            except (OSError, ValueError) as e:
                # описание не читается (например, Syncthing как раз его меняет): не затираем его звездой
                sys.exit(f"oboi-index: не читается {sp} ({e}), избранное не изменено")
        m["favorite"] = (not m.get("favorite")) if mode == "toggle" else (mode == "on")
        if stamp(sp) == before:
            write_json(sp, m)
            return m["favorite"]
        time.sleep(0.2)
    sys.exit(f"oboi-index: {sp} всё время меняется, избранное не изменено")


def pictures_dir():
    """Папка картинок по XDG (~/.config/user-dirs.dirs), иначе ~/Pictures."""
    try:
        base = os.environ.get("XDG_CONFIG_HOME", os.path.join(HOME, ".config"))
        for line in open(os.path.join(base, "user-dirs.dirs"), encoding="utf-8"):
            if line.startswith("XDG_PICTURES_DIR="):
                return os.path.expandvars(line.split("=", 1)[1].strip().strip('"'))
    except OSError:
        pass
    return os.path.join(HOME, "Pictures")


def main():
    ap = argparse.ArgumentParser(prog="oboi-index")
    ap.add_argument("--dir", action="append")
    ap.add_argument("--out", default=os.path.join(CACHE, "index.json"))
    ap.add_argument("--thumbs", default=os.path.join(CACHE, "thumbs"))
    ap.add_argument("--quiet", action="store_true")
    ap.add_argument("--favorite", nargs=2, metavar=("PATH", "on|off|toggle"))
    a = ap.parse_args()
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    # один индексатор за раз: быстрые клики по звезде иначе пишут индекс и сайдкары наперегонки
    lock = open(os.path.join(os.path.dirname(a.out), "index.lock"), "w")
    fcntl.flock(lock, fcntl.LOCK_EX)
    if a.favorite:
        on = set_favorite(*a.favorite)
        print("favorite" if on else "plain")
        # звезда меняет одну запись: правим её в индексе и не обходим всю библиотеку
        try:
            with open(a.out, encoding="utf-8") as fh:
                idx = json.load(fh)
            p = os.path.abspath(os.path.expanduser(a.favorite[0]))
            for e in idx.get("items", []):
                if e.get("path") == p:
                    e["favorite"] = on
                    write_json(a.out, idx)
                    return
        except (OSError, ValueError, AttributeError):
            pass
    dirs = a.dir or config_dirs() or [pictures_dir()]
    os.makedirs(a.thumbs, exist_ok=True)

    old = {}
    try:
        for e in json.load(open(a.out, encoding="utf-8")).get("items", []):
            old[e["path"]] = e
    except (OSError, ValueError, KeyError):
        pass

    items, made, bad = [], 0, 0
    sfavs = state_favs()
    for root, name in scan(dirs):
        path = os.path.join(root, name)
        try:
            st = os.stat(path)
        except OSError:
            continue
        key = hashlib.sha1(f"{path}|{st.st_size}|{int(st.st_mtime)}".encode()).hexdigest()[:20]
        thumb = os.path.join(a.thumbs, key + ".jpg")
        prev = old.get(path)
        try:
            if prev and prev.get("key") == key and os.path.exists(thumb) and "hue" in prev:
                w, h, hue, cov = prev["w"], prev["h"], prev["hue"], prev.get("hue_cov", 0)
            else:
                if not (prev and prev.get("key") == key and os.path.exists(thumb)):
                    w, h = make_thumb(path, thumb); made += 1
                else:
                    w, h = prev["w"], prev["h"]
                hue, cov = hue_of(thumb)
        except Exception as ex:   # битая картинка не должна ронять весь индекс
            bad += 1
            if not a.quiet:
                print(f"пропуск {path}: {ex}", file=sys.stderr)
            continue
        m = read_meta(root, name)
        title = text(m.get("title")).strip() or os.path.splitext(name)[0].replace("_", " ").replace("-", " ").strip() or name
        fav = sfavs[path] if isinstance(sfavs.get(path), bool) else bool(m.get("favorite"))
        items.append({
            "path": path, "file": name, "key": key, "thumb": thumb, "w": w, "h": h,
            "portrait": h > w,   # лента такие не показывает
            "hue": hue, "hue_cov": cov, "favorite": fav,
            "title": title, "style": text(m.get("style")),
            "description": text(m.get("description_ru")),
            "keywords": words(m.get("keywords_ru")), "tags": words(m.get("tags")),
            "source": text(m.get("source")),
            "search": " ".join([name, title, text(m.get("style")), text(m.get("description_ru")),
                                " ".join(words(m.get("keywords_ru"))), " ".join(words(m.get("tags"))),
                                text(m.get("query")), f"{w}x{h}", "4k" if w >= 3840 else ""]).lower(),
        })

    # Папка пропала (не смонтирован диск, отвалился NFS): её картинки и миниатюры не выбрасываем,
    # иначе после возвращения папки всё индексировалось бы заново и терялся бы прежний список.
    gone = [os.path.join(os.path.expanduser(d), "") for d in dirs if not os.path.isdir(os.path.expanduser(d))]
    if gone:
        seen = {e["path"] for e in items}
        items += [dict(e, missing=True) for p, e in old.items() if p not in seen and any(p.startswith(g) for g in gone)]

    live = {os.path.basename(e["thumb"]) for e in items}
    for f in os.listdir(a.thumbs):          # убрать миниатюры удалённых картинок
        if f.endswith(".jpg") and f not in live:
            try: os.remove(os.path.join(a.thumbs, f))
            except OSError: pass

    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(a.out), suffix=".tmp")
    with os.fdopen(fd, "w", encoding="utf-8") as fh:
        json.dump({"version": 1, "items": items}, fh, ensure_ascii=False)
    os.replace(tmp, a.out)
    if not a.quiet:
        print(f"обоев: {len(items)}, новых миниатюр: {made}, пропущено: {bad}")


if __name__ == "__main__":
    main()
