#!/usr/bin/env python3
"""Смысловой поиск обоев на SigLIP2 (локально, на процессоре).

oboi-semantic index            посчитать векторы картинок, которых ещё нет в кэше
oboi-semantic query "текст"    найти (JSON: [[путь, близость], …])
oboi-semantic serve            тёплый режим для ленты: строка JSON на входе, строка JSON на выходе
oboi-semantic bench            замеры: холодный старт, запросы, память

Модель: google/siglip2-base-patch16-224 (Apache-2.0), экспорт onnx-community, квантованные части
vision_model_quantized.onnx и text_model_quantized.onnx в ~/.local/share/oboi/models/siglip2.
Векторы лежат в ~/.cache/oboi/semantic.npz по ключу картинки из индекса oboi-index.
Нужны пакеты: python-onnxruntime-cpu, python-tokenizers, python-numpy, python-pillow.
"""
import json, os, sys, time

HOME = os.path.expanduser("~")
CACHE = os.environ.get("OBOI_CACHE") or os.path.join(os.environ.get("XDG_CACHE_HOME") or os.path.join(HOME, ".cache"), "oboi")
INDEX = os.path.join(CACHE, "index.json")
VECS = os.path.join(CACHE, "semantic.npz")
MODEL = os.environ.get("OBOI_MODEL", os.path.join(
    os.environ.get("XDG_DATA_HOME") or os.path.join(HOME, ".local", "share"), "oboi", "models", "siglip2"))
MAX_LEN = 64          # SigLIP2 учили на текстах, дополненных до 64 токенов
SIZE = 224


def session(name, threads):
    import onnxruntime as ort
    o = ort.SessionOptions()
    o.intra_op_num_threads = threads
    o.inter_op_num_threads = 1
    o.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
    return ort.InferenceSession(os.path.join(MODEL, name), o, providers=["CPUExecutionProvider"])


def pick_output(sess, prefer):
    names = [o.name for o in sess.get_outputs()]
    for p in prefer:
        if p in names:
            return p
    for o in sess.get_outputs():          # запасной вариант: первый двумерный выход
        if len(o.shape) == 2:
            return o.name
    return names[0]


def normalize(v):
    import numpy as np
    return v / np.maximum(np.linalg.norm(v, axis=-1, keepdims=True), 1e-12)


def load_vecs():
    import numpy as np
    if not os.path.exists(VECS):
        return [], np.zeros((0, 768), dtype=np.float32), ""
    z = np.load(VECS, allow_pickle=False)
    return list(z["keys"]), z["vecs"].astype(np.float32), str(z["model"])


def save_vecs(keys, vecs, model_id):
    import numpy as np
    tmp = VECS + ".tmp.npz"
    np.savez(tmp, keys=np.array(keys), vecs=vecs.astype(np.float16), model=np.array(model_id))
    os.replace(tmp, VECS)


def model_id():
    try:
        with open(os.path.join(MODEL, "SHA256SUMS")) as f:
            return f.read().strip().replace("\n", ";")[:400]
    except OSError:
        return "siglip2-base-patch16-224-quantized"


def image_tensor(path):
    import numpy as np
    from PIL import Image
    with Image.open(path) as im:
        im = im.convert("RGB").resize((SIZE, SIZE), Image.BICUBIC)   # как при обучении: растянуть до квадрата
        a = (np.asarray(im, dtype=np.float32) / 255.0 - 0.5) / 0.5
    return a.transpose(2, 0, 1)[None]


def index_items(strict=True):
    """Картинки индекса, кроме записей пропавших папок. Вертикальные тоже: на вертикальном мониторе
    лента показывает их, и искать по смыслу их надо. strict=False: индекса ещё нет, это не ошибка
    (тёплый помощник стартует вместе с первым индексом и подхватит его, когда тот появится)."""
    try:
        items = json.load(open(INDEX, encoding="utf-8"))["items"]
    except (OSError, ValueError, KeyError):
        if strict:
            sys.exit("oboi-semantic: нет индекса, сначала oboi-index")
        return []
    return [e for e in items if not e.get("missing")]


def cmd_index(quiet=False):
    import numpy as np
    try:
        os.nice(10)                    # индексация не должна мешать ленте и анимациям
    except OSError:
        pass
    items = index_items()
    keys, vecs, mid = load_vecs()
    changed = mid != model_id()
    if mid and changed:                # модель сменилась: старые векторы несовместимы
        keys, vecs = [], vecs[:0]
    have = dict(zip(keys, range(len(keys))))
    todo = [e for e in items if e["key"] not in have]
    live = {e["key"] for e in items}
    keep = [i for i, k in enumerate(keys) if k in live]
    changed = changed or len(keep) != len(keys)
    keys, vecs = [keys[i] for i in keep], vecs[keep] if len(keep) else vecs[:0]
    if todo:
        sess = session("vision_model_quantized.onnx", 4)
        inp = sess.get_inputs()[0].name
        out = pick_output(sess, ["pooler_output", "image_embeds"])
        t0 = time.time(); new = []
        for e in todo:
            try:
                v = sess.run([out], {inp: image_tensor(e["thumb"])})[0][0]
            except Exception as ex:          # битая миниатюра не роняет весь проход
                if not quiet:
                    print(f"пропуск {e['path']}: {ex}", file=sys.stderr)
                continue
            new.append((e["key"], v))
        if new:
            changed = True
            keys += [k for k, _ in new]
            vecs = np.concatenate([vecs.reshape(-1, len(new[0][1])) if len(vecs) else np.zeros((0, len(new[0][1])), np.float32),
                                   normalize(np.stack([v for _, v in new]))])
        if not quiet:
            print(f"новых векторов: {len(new)} за {time.time() - t0:.1f} с "
                  f"({(time.time() - t0) / max(1, len(new)) * 1000:.0f} мс на картинку)")
    if changed:                        # без перемен файл не трогаем: serve перечитывает его по времени изменения
        save_vecs(keys, vecs, model_id())
    if not quiet:
        print(f"всего векторов: {len(keys)}")


class Text:
    def __init__(self, threads=2):
        from tokenizers import Tokenizer
        self.tok = Tokenizer.from_file(os.path.join(MODEL, "tokenizer.json"))
        self.tok.enable_padding(length=MAX_LEN, pad_id=self._pad_id())
        self.tok.enable_truncation(MAX_LEN)
        self.sess = session("text_model_quantized.onnx", threads)
        self.inputs = [i.name for i in self.sess.get_inputs()]
        self.out = pick_output(self.sess, ["pooler_output", "text_embeds"])

    def _pad_id(self):
        try:
            cfg = json.load(open(os.path.join(MODEL, "tokenizer_config.json")))
            pad = cfg.get("pad_token", "<pad>")
            pad = pad["content"] if isinstance(pad, dict) else pad
            return self.tok.token_to_id(pad) or 0
        except (OSError, ValueError):
            return 0

    def embed(self, text):
        import numpy as np
        enc = self.tok.encode(text.lower())     # SigLIP2 учили на текстах в нижнем регистре
        feed = {"input_ids": np.array([enc.ids], dtype=np.int64)}
        if "attention_mask" in self.inputs:
            feed["attention_mask"] = np.array([enc.attention_mask], dtype=np.int64)
        feed = {k: v for k, v in feed.items() if k in self.inputs}
        return normalize(self.sess.run([self.out], feed)[0][0])


# Посторонние запросы. Средняя близость картинки к ним показывает, насколько она «магнит»:
# такие картинки (скриншоты, однотонные, с текстом) близки к любому запросу и забивают выдачу.
HUB_BANK = ["кошка", "машина", "еда", "текст", "человек", "здание", "собака", "цветок", "компьютер", "книга",
            "дорога", "лицо", "a cat", "a car", "food", "text", "a person", "a building", "a dog", "a flower",
            "a computer", "a book"]
MIN_SCORE = 0.03      # ниже этого после поправки модель скорее гадает, чем узнаёт
NEAR_BEST = 0.7       # и не дальше этой доли от лучшего совпадения


class Searcher:
    def __init__(self):
        import numpy as np
        self.text = Text()
        self.bank = np.stack([self.text.embed(t) for t in HUB_BANK])
        self.stamp = None
        self.reload()

    def reload(self):
        st = (os.path.getmtime(VECS) if os.path.exists(VECS) else 0, os.path.getmtime(INDEX) if os.path.exists(INDEX) else 0)
        if st == self.stamp:
            return
        self.stamp = st
        keys, self.vecs, _ = load_vecs()
        by_key = {e["key"]: e["path"] for e in index_items(strict=False)}
        idx = [i for i, k in enumerate(keys) if k in by_key]
        self.paths = [by_key[keys[i]] for i in idx]
        self.vecs = self.vecs[idx] if idx else self.vecs[:0]
        self.hub = (self.vecs @ self.bank.T).mean(1) if len(self.vecs) else self.vecs[:0, 0]

    def search(self, q, n=40):
        import numpy as np
        self.reload()
        if not len(self.paths) or not q.strip():
            return []
        s = self.vecs @ self.text.embed(q) - self.hub
        order = np.argsort(-s)[:n]
        best = float(s[order[0]])
        return [[self.paths[i], round(float(s[i]), 4)] for i in order
                if s[i] >= MIN_SCORE and s[i] >= best * NEAR_BEST]


def cmd_query(q):
    print(json.dumps(Searcher().search(q), ensure_ascii=False))


def cmd_serve():
    sr = Searcher()
    print(json.dumps({"ready": True}), flush=True)
    for line in sys.stdin:
        try:
            req = json.loads(line)
            t0 = time.time()
            res = sr.search(req.get("q", ""), int(req.get("n", 40)))
            print(json.dumps({"id": req.get("id"), "q": req.get("q", ""), "ms": round((time.time() - t0) * 1000),
                              "results": res}, ensure_ascii=False), flush=True)
        except Exception as ex:
            print(json.dumps({"id": None, "error": str(ex)}), flush=True)


def rss_mb():
    try:
        for l in open("/proc/self/status"):
            if l.startswith("VmRSS"):
                return int(l.split()[1]) / 1024
    except OSError:
        pass
    return 0


def cmd_bench(queries):
    import statistics
    t0 = time.time(); sr = Searcher(); cold = time.time() - t0
    times = []
    for q in queries * 3:
        t = time.time(); sr.search(q); times.append((time.time() - t) * 1000)
    times.sort()
    print(json.dumps({"cold_start_s": round(cold, 2), "queries": len(times),
                      "median_ms": round(statistics.median(times)), "p95_ms": round(times[int(len(times) * 0.95) - 1]),
                      "rss_mb": round(rss_mb()), "vectors": len(sr.paths)}, ensure_ascii=False))


def main():
    a = sys.argv[1:]
    if not a or a[0] not in ("index", "query", "serve", "bench"):
        sys.exit(__doc__)
    if a[0] == "index":
        cmd_index(quiet="--quiet" in a)
    elif a[0] == "query":
        cmd_query(" ".join(a[1:]))
    elif a[0] == "serve":
        cmd_serve()
    else:
        cmd_bench(a[1:] or ["закат", "дождь"])


if __name__ == "__main__":
    main()
