# Helpers

Three programs do the work QML is not suited for. Each exists as a Python module in `bin/` and is started through a small POSIX `sh` launcher of the same name:

| Launcher | Module | Needs |
|---|---|---|
| `bin/oboi-index` | `oboi_index.py` | Pillow |
| `bin/oboi-fetch` | `oboi_fetch.py` | only the standard library |
| `bin/oboi-semantic` | `oboi_semantic.py` | onnxruntime, tokenizers, numpy, Pillow and the model (optional) |

## How a launcher chooses: prebuilt binary or Python

`bin/oboi-helper` is optional: a Nuitka onefile build of all three modules with their libraries (see [building-and-releasing.md](building-and-releasing.md)). It is not in git; users download it from the release.

```
bin/oboi-<x> args
  ├─ bin/oboi-helper exists and is executable?
  │    └─ helper_ready (bin/helper-ready.sh): has this exact binary already run here?
  │         ├─ yes (mark ~/.cache/oboi/helper-ok-<size>-<mtime> and its unpack folder exist) → run it
  │         └─ no → under a lock, run "oboi-helper where" and "oboi-helper index --help";
  │                 if both work, write the mark and run it; otherwise use Python
  └─ python3 bin/oboi_<x>.py args
```

Details that matter when you change this:

- **The lock** is a `mkdir` lock (`~/.cache/oboi/helper.lock.d`), not `flock`, because BusyBox `flock` has no timeout. A lock older than two minutes is treated as left over by a killed process; waiting gives up after 120 s and Python is used. `StartupCheck.qml` allows 150 s. The first unpack must not run twice in parallel: two processes unpacking the same onefile at once crash with SIGBUS.
- **The binary runs as a child**, not via `exec`. The launcher forwards TERM/INT/HUP to it (Quickshell kills the launcher when a search is cancelled) and passes stdin explicitly (the semantic helper reads requests from stdin; a background job would otherwise get `/dev/null`). If the child exits with 126 or 127 (it could not be executed, e.g. NixOS after `nix-ld` was switched off) the launcher falls back to Python.
- **Failures are not remembered.** The next start tries again, so enabling `nix-ld` or fixing permissions just works.
- `StartupCheck.qml` uses the same `helper_ready` decision, so DMS refuses to enable the plugin only when neither a working binary nor `python3` with Pillow is available.
- On NixOS without `programs.nix-ld.enable`, the binary cannot run (the dynamic loader is a stub). That is expected: Python from `python3.withPackages` is used.

## `oboi-index`

```
oboi-index [--dir DIR]... [--out INDEX.json] [--thumbs DIR] [--quiet]
oboi-index --favorite PATH on|off|toggle [same options]
```

- Without `--dir` it reads `dirs` from `~/.config/oboi/config.json`, otherwise uses the XDG Pictures folder.
- Defaults for `--out` and `--thumbs` come from `OBOI_CACHE` (`~/.cache/oboi`).
- One run at a time per cache folder (`index.lock`).
- `--favorite` changes one picture: it writes the sidecar (or `favorites.json` for read-only folders) and prints `favorite` or `plain`. If the picture is already in the index, that entry is updated in place and the program exits; otherwise (or if the index is missing) a full scan with the given `--dir` follows. Exits 1 if the sidecar is unreadable, not an object, or keeps changing.
- A full scan reuses thumbnails whose key (path, size, mtime) did not change, so a warm scan of a large library is fast. The index is written only at the end of a scan (atomically).

## `oboi-fetch`

```
oboi-fetch --search=QUERY [--page N] [filters]      one page of results as JSON (used by the picker)
oboi-fetch --to DIR --id ID [--style NAME] [--purity B] [--atleast WxH]   save one picture with its sidecar
oboi-fetch --to DIR --query Q [--query Q]... [--per-query N] [--style NAME] [--categories B] [--sorting S]
search filters: --atleast 3840x2160  --ratios 16x9,16x10  --categories 111  --purity 100  --sorting toplist
```

Pass the query as `--search=…` (with `=`), so queries that start with `-` (wallhaven's exclusion syntax) are not taken as options.

Search output:

```json
{ "page": 1, "last_page": 4, "total": 91,
  "results": [ { "id": "r7jjr1", "thumb": "https://th.wallhaven.cc/lg/…jpg", "resolution": "5120x2880",
                 "colors": ["#…"], "category": "general", "purity": "sfw", "url": "https://wallhaven.cc/w/r7jjr1" } ] }
```

A failed search prints `{"error": "…", "results": []}`.

Save output: `{"saved": "/absolute/path/wh-r7jjr1.jpg"}` (also when the file already exists) or `{"error": "…"}`. A single save checks only purity and minimum resolution. If `DIR` cannot be written, the picture goes to `<Pictures>/Wallpapers` and that path is returned.

Batch mode (`--query`) is a tool for filling a library: it always uses SFW, 3840x2160 and 16:9/16:10, takes only `--categories` and `--sorting` (default top of the last year), prints one tab-separated line per saved picture and a count on stderr.

Network behaviour:

- One request every 1.4 s at most within one process (wallhaven allows 45 per minute); separate processes do not coordinate.
- Each request has a deadline: 30 s for a JSON request (a search page, or the picture info inside a save), 180 s for an image download, so a save can take up to 30 + 180 s. Up to 4 attempts, each with a 15 s (JSON) or 60 s (image) socket timeout. Responses are capped at 8 MB (JSON) and 200 MB (image). Every read checks the deadline; a body shorter than its `Content-Length` is rejected.
- On HTTP 429 it waits for `Retry-After`, within the deadline.
- The API key goes in the `X-API-Key` header, never in the URL. It is dropped if a redirect leads to another host, port or plain HTTP.
- Downloads are written to a private temporary file and renamed; an existing file is never overwritten.

## `oboi-semantic`

```
oboi-semantic index [--quiet]   compute vectors for pictures that have none yet (runs with nice 10)
oboi-semantic query TEXT        print [[path, score], ...]
oboi-semantic serve             warm mode for the picker, one JSON request per line on stdin
oboi-semantic bench [QUERY...]  timings and memory
```

`serve` protocol:

```
→ (on start)  {"ready": true}
← {"id": 7, "q": "desert", "n": 40}
→ {"id": 7, "q": "desert", "ms": 62, "results": [["/path/a.jpg", 0.048], ...]}
→ {"id": null, "error": "…"}            (on a bad request)
```

Without the model or its packages, `serve` exits before `{"ready": true}` and the picker keeps word search. With no arguments the program prints its usage and exits 1.

The model folder holds the seven files fetched by `tools/get-model.sh` and `SHA256SUMS`; the checksums identify the model, and changing them makes `semantic.npz` rebuild from scratch. Vectors are computed from the thumbnails, not the originals.

The model is SigLIP2 base (patch16, 224) quantized to ONNX, from `onnx-community/siglip2-base-patch16-224-ONNX`. Scores are corrected for "hub" pictures that match every query (the mean similarity to a fixed bank of unrelated words is subtracted), results below 0.03 or below 70 % of the best score are dropped. It works well for English queries and weakly for others.
