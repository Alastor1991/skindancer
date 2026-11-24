#!/usr/bin/env python3
"""Скачивает обои с wallhaven.cc вместе с описанием.

oboi-fetch --to DIR --query "surreal" [--query ...] [--per-query N] [--style NAME]
oboi-fetch --search "закат" [--page N]     страница результатов в JSON (для ленты)
oboi-fetch --to DIR --id ID [--style NAME]  скачать одну картинку по номеру wallhaven

Фильтры для --search и --id: --atleast 3840x2160 (или пусто: любое разрешение),
--ratios 16x9,16x10 (пусто: любые), --categories 111 (общие/аниме/люди),
--purity 100 (sfw/sketchy/nsfw), --sorting relevance|toplist|date_added|views|favorites|random.
Без ключей по умолчанию: SFW от 4K. NSFW wallhaven отдаёт только с API-ключом:
"wallhaven_apikey" в ~/.config/oboi/config.json.

Рядом с картинкой в DIR/.oboi/<имя>.json кладётся: источник, теги, цвета,
разрешение, стиль. Уже скачанные (по id wallhaven) пропускаются.
Только стандартная библиотека Python.
"""
import argparse, json, os, re, ssl, sys, tempfile, time, urllib.parse, urllib.request

API = "https://wallhaven.cc/api/v1"
PURITY_NAMES = ("sfw", "sketchy", "nsfw")


def apikey():
    # плагин DMS передаёт ключ переменной окружения, самостоятельные «Обои» хранят его в config.json
    if os.environ.get("OBOI_WALLHAVEN_KEY"):
        return os.environ["OBOI_WALLHAVEN_KEY"]
    p = os.path.join(os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config")), "oboi", "config.json")
    try:
        return json.load(open(p, encoding="utf-8")).get("wallhaven_apikey", "")
    except (OSError, ValueError):
        return ""


def allowed(purity_bits):
    """'110' -> {'sfw', 'sketchy'}"""
    return {n for n, b in zip(PURITY_NAMES, purity_bits.ljust(3, "0")) if b == "1"} or {"sfw"}


def big_enough(res, atleast):
    if not atleast:
        return True
    w, h = (int(x) for x in (res or "0x0").split("x"))
    mw, mh = (int(x) for x in atleast.split("x"))
    return w >= mw and h >= mh


def api(path, params=None):
    # ключ идёт заголовком, а не в адресе: адрес попадает в тексты ошибок, и ключ утёк бы в ленту
    key = apikey()
    return get(f"{API}/{path}" + (f"?{urllib.parse.urlencode(params)}" if params else ""),
               headers={"X-API-Key": key} if key else None)
UA = "oboi-fetch/1.0 (personal wallpaper library)"
_last = [0.0]


def _find_ca():
    """Корневые сертификаты. Собранный oboi-helper несёт OpenSSL из AlmaLinux, и тот ищет их
    по пути Fedora; в Debian, Ubuntu, Arch и openSUSE они лежат иначе, и HTTPS без этого падает."""
    def usable(f):
        try:
            return os.path.getsize(f) > 1000       # пустой или битый файл не годится
        except OSError:
            return False
    if os.environ.get("SSL_CERT_FILE") or usable(ssl.get_default_verify_paths().cafile or ""):
        return
    for f in ("/etc/ssl/certs/ca-certificates.crt",      # Debian, Ubuntu, Arch, Gentoo
              "/etc/pki/tls/certs/ca-bundle.crt",         # Fedora, RHEL
              "/etc/ssl/ca-bundle.pem",                   # openSUSE
              "/var/lib/ca-certificates/ca-bundle.pem",   # openSUSE
              "/etc/ssl/cert.pem"):                       # Alpine, Void, NixOS
        if usable(f):
            os.environ["SSL_CERT_FILE"] = f
            return


_find_ca()


class _KeepKeyHome(urllib.request.HTTPRedirectHandler):
    """Переадресация на другой сайт не уносит ключ wallhaven: заголовок X-API-Key снимается."""
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        new = super().redirect_request(req, fp, code, msg, headers, newurl)
        a, b = urllib.parse.urlsplit(req.full_url), urllib.parse.urlsplit(newurl)
        # ключ остаётся только при переходе внутри того же https-сайта: не на http, не на другой хост или порт
        if new is not None and (b.scheme != "https" or (a.hostname, a.port) != (b.hostname, b.port)):
            new.remove_header("X-api-key")
        return new


_open = urllib.request.build_opener(_KeepKeyHome).open


def get(url, binary=False, tries=4, headers=None):
    # Общий срок на все попытки: поиск в ленте не должен висеть минутами без сети.
    deadline = time.monotonic() + (180 if binary else 30)
    why = "нет ответа"
    for i in range(tries):
        wait = 1.4 - (time.time() - _last[0])   # лимит wallhaven: 45 запросов в минуту
        if wait > 0:
            time.sleep(wait)
        _last[0] = time.time()
        left = deadline - time.monotonic()
        if left <= 1:
            break
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA, **(headers or {})})
            with _open(req, timeout=min(60 if binary else 15, left)) as r:
                # читаем кусками: медленный сервер не растянет запрос дольше срока, огромный ответ не съест память
                buf, limit = bytearray(), (200 if binary else 8) * 1024 * 1024
                while chunk := r.read(65536):
                    buf += chunk
                    if len(buf) > limit or time.monotonic() > deadline:
                        raise TimeoutError("ответ слишком большой или слишком медленный")
                data = bytes(buf)
            return data if binary else json.loads(data)
        except urllib.error.HTTPError as e:
            if e.code != 429:
                raise
            why = "HTTP 429, wallhaven просит подождать"
            pause = 15 * (i + 1)
            try:
                pause = max(0, int(e.headers.get("Retry-After", pause)))
            except (TypeError, ValueError):
                pass                        # HTTP-дата или мусор: остаётся своя пауза
        except (urllib.error.URLError, TimeoutError, OSError) as e:
            why = getattr(e, "reason", None) or e
            pause = 3 * (i + 1)
        if i + 1 < tries and time.monotonic() + pause < deadline:
            time.sleep(pause)
        else:
            break
    raise RuntimeError(f"не удалось получить {url.split('?')[0]}: {why}")


def known_ids(meta_dir):
    ids = set()
    if os.path.isdir(meta_dir):
        for n in os.listdir(meta_dir):
            if n.endswith(".json"):
                try:
                    j = json.load(open(os.path.join(meta_dir, n)))
                    if j.get("wallhaven_id"):
                        ids.add(j["wallhaven_id"])
                except (OSError, ValueError):
                    pass
    return ids


def write_meta(path, meta):
    """Атомарно: Syncthing не должен увидеть и разослать недописанный JSON."""
    tmp = path + f".{os.getpid()}.tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=1)
    os.replace(tmp, path)


def save_bytes(dest, data):
    """Запись картинки через свой временный файл: два сохранения одной картинки не портят друг другу файл."""
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(dest), prefix=".oboi-", suffix=".part")
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(data)
        os.replace(tmp, dest)
    except BaseException:
        if os.path.exists(tmp):
            os.remove(tmp)
        raise


def save_one(wid, to, style="", query="", purity="100", atleast="3840x2160"):
    """Скачать одну картинку с проверкой чистоты и разрешения, рядом положить описание."""
    if not re.fullmatch(r"[A-Za-z0-9]{1,16}", wid or ""):      # id идёт в имя файла и в адрес
        raise RuntimeError(f"странный id wallhaven: {wid!r}")
    meta_dir = os.path.join(to, ".oboi")
    os.makedirs(meta_dir, exist_ok=True)
    info = api(f"w/{wid}").get("data", {})
    if info.get("purity") not in allowed(purity):
        raise RuntimeError(f"чистота {info.get('purity')} выключена в настройках, пропускаю")
    if not big_enough(info.get("resolution"), atleast):
        raise RuntimeError(f"меньше {atleast} ({info.get('resolution')})")
    name = f"wh-{wid}{os.path.splitext(info['path'])[1]}"
    dest = os.path.join(to, name)
    if not os.path.exists(dest):
        save_bytes(dest, get(info["path"], binary=True))
    meta = {"file": name, "source": info.get("url"), "wallhaven_id": wid, "resolution": info.get("resolution"),
            "category": info.get("category"), "colors": info.get("colors", []), "style": style, "query": query,
            "tags": [t["name"] for t in info.get("tags", [])], "description_ru": "", "keywords_ru": []}
    mp = os.path.join(meta_dir, name + ".json")
    if not os.path.exists(mp):
        write_meta(mp, meta)
    return dest


def search_page(q, page, atleast="3840x2160", ratios="16x9,16x10", categories="111", purity="100", sorting=""):
    """Одна страница поиска для ленты, без скачивания картинок."""
    params = {"q": q, "purity": purity, "categories": categories, "order": "desc", "page": str(page),
              "sorting": sorting or ("relevance" if q.strip() else "toplist")}
    if atleast:
        params["atleast"] = atleast
    if ratios:
        params["ratios"] = ratios
    if params["sorting"] == "toplist":
        params["topRange"] = "1y"
    res = api("search", params)
    ok = allowed(purity)
    out = [{"id": w["id"], "thumb": w["thumbs"]["large"], "resolution": w["resolution"], "colors": w.get("colors", []),
            "category": w.get("category"), "purity": w.get("purity"), "url": w.get("url")}
           for w in res.get("data", []) if w.get("purity") in ok]
    meta = res.get("meta", {})
    return {"page": page, "last_page": meta.get("last_page", page), "total": meta.get("total"), "results": out}


def main():
    ap = argparse.ArgumentParser(prog="oboi-fetch")
    ap.add_argument("--to")
    ap.add_argument("--query", action="append")
    ap.add_argument("--search")
    ap.add_argument("--page", type=int, default=1)
    ap.add_argument("--id")
    ap.add_argument("--per-query", type=int, default=10)
    ap.add_argument("--style", default="")
    ap.add_argument("--sorting", default="", help="по умолчанию: relevance для поиска, toplist для пакета")
    ap.add_argument("--categories", default="111", help="general/anime/people, например 010 = только аниме")
    ap.add_argument("--atleast", default="3840x2160", help="пусто: любое разрешение")
    ap.add_argument("--ratios", default="16x9,16x10", help="пусто: любые пропорции")
    ap.add_argument("--purity", default="100", help="sfw/sketchy/nsfw битами: 100, 110, 111")
    a = ap.parse_args()
    if a.search is not None:
        try:
            print(json.dumps(search_page(a.search, a.page, a.atleast, a.ratios, a.categories, a.purity,
                                         a.sorting),
                             ensure_ascii=False))
        except Exception as ex:
            print(json.dumps({"error": str(ex), "results": []}, ensure_ascii=False))
        return
    if not a.to:
        sys.exit("oboi-fetch: нужен --to")
    if a.id:
        try:
            print(json.dumps({"saved": save_one(a.id, os.path.expanduser(a.to), a.style, "", a.purity, a.atleast)},
                             ensure_ascii=False))
        except Exception as ex:
            print(json.dumps({"error": str(ex)}, ensure_ascii=False))
        return
    if not a.query:
        sys.exit("oboi-fetch: нужен --query, --search или --id")

    meta_dir = os.path.join(a.to, ".oboi")
    os.makedirs(meta_dir, exist_ok=True)
    have = known_ids(meta_dir)
    got = 0
    for q in a.query:
        params = {"q": q, "purity": "100", "categories": a.categories, "atleast": "3840x2160",
                  "ratios": "16x9,16x10", "sorting": a.sorting or "toplist", "topRange": "1y", "order": "desc"}
        res = get(f"{API}/search?{urllib.parse.urlencode(params)}")
        n = 0
        for w in res.get("data", []):
            if n >= a.per_query:
                break
            if w["id"] in have or w.get("purity") != "sfw":
                continue
            info = get(f"{API}/w/{w['id']}").get("data", {})
            if info.get("purity") != "sfw":
                continue
            ext = os.path.splitext(info["path"])[1]
            name = f"wh-{w['id']}{ext}"
            dest = os.path.join(a.to, name)
            save_bytes(dest, get(info["path"], binary=True))
            meta = {
                "file": name, "source": info.get("url"), "wallhaven_id": w["id"],
                "resolution": info.get("resolution"), "category": info.get("category"),
                "colors": info.get("colors", []), "style": a.style, "query": q,
                "tags": [t["name"] for t in info.get("tags", [])],
                "description_ru": "", "keywords_ru": [],
            }
            write_meta(os.path.join(meta_dir, name + ".json"), meta)
            have.add(w["id"]); n += 1; got += 1
            print(f"{name}\t{info.get('resolution')}\t{q}\t{', '.join(meta['tags'][:6])}", flush=True)
    print(f"скачано: {got}", file=sys.stderr)


if __name__ == "__main__":
    main()
