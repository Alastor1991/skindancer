# Files and formats

## What is written where

| Path | Written by | Contents |
|---|---|---|
| `~/.cache/oboi/dms/index.json` | `oboi-index` (plugin) | The library index, see below |
| `~/.cache/oboi/dms/thumbs/<key>.jpg` | `oboi-index` | Thumbnails: JPEG quality 84, at most 540 px high and 2160 px wide, never upscaled |
| `~/.cache/oboi/dms/semantic.npz` | `oboi-semantic` | Image vectors for search by meaning (only with the model) |
| `~/.cache/oboi/index.json`, `thumbs/`, `semantic.npz` | same | The same for standalone mode |
| `~/.cache/oboi/helper-<hash>/` | prebuilt `oboi-helper` | The bundle unpacks itself here on first run (~180 MB). Other versions untouched for a day are removed |
| `~/.cache/oboi/helper-ok-<size>-<mtime>` | launchers | Marks that this exact binary runs here; contains its unpack folder |
| `index.lock` next to each `index.json`, `~/.cache/oboi/helper.lock.d`, `~/.local/state/oboi/favorites.json.lock` | helpers | Locks |
| `<wallpaper folder>/.oboi/<file>.json` | `oboi-index`, `oboi-fetch` | Sidecar file with favourite flag, titles, tags |
| `~/.local/state/oboi/favorites.json` | `oboi-index` | Favourites of pictures in folders that cannot be written (system wallpapers, read-only mounts, `/nix/store`) |
| `~/.local/share/oboi/models/siglip2/` | `tools/get-model.sh` | The optional SigLIP2 model |
| `~/.config/oboi/config.json` | standalone picker | Standalone settings |

Everything under `~/.cache/oboi` can be deleted; it is rebuilt on the next open.

## Sidecar file: `<folder>/.oboi/<file name>.json`

A small JSON object next to each picture that has extra information. All fields are optional, unknown fields are kept.

| Field | Type | Used for |
|---|---|---|
| `favorite` | bool | The star |
| `title` | string | Caption title and search. Default: the file name without extension, `_` and `-` replaced by spaces |
| `description_ru` | string | Caption description and search. The `_ru` suffix is historical; any language works |
| `keywords_ru` | array of strings | First five are shown under the caption; all are searched. Any language |
| `tags` | array of strings | Searched (wallhaven tags are stored here) |
| `style` | string | Shown and searched (e.g. `wallhaven`) |
| `query` | string | Searched (the query of a batch download; empty for pictures saved from the picker) |
| `source` | string | Where it came from (URL) |
| `wallhaven_id`, `resolution`, `category`, `colors`, `file` | | Written by `oboi-fetch` for pictures saved from wallhaven. Batch downloads skip ids that already have a sidecar; a single save skips when `wh-<id>.<ext>` already exists and does not overwrite an existing sidecar |

Example:

```json
{
  "file": "melting-clocks.jpg",
  "favorite": true,
  "title": "Melting clocks by the sea",
  "description_ru": "Soft clocks hang from a cliff and a dry tree, warm ochre dusk.",
  "keywords_ru": ["surrealism", "clocks", "desert", "sea"],
  "tags": ["dali"]
}
```

A sidecar that is not valid JSON or not an object is ignored for indexing; fields of the wrong type are dropped one by one. Neither breaks the index. Starring a picture whose sidecar is unreadable or not an object is refused (exit 1) rather than overwriting it. Writes are atomic (temporary file + rename). If Syncthing or another program changes the sidecar while a star is being written, the write is retried up to five times and never overwrites newer tags.

## `index.json`

```json
{ "version": 1, "items": [ { ... }, ... ] }
```

Each item:

| Field | Meaning |
|---|---|
| `path`, `file` | Absolute path and file name |
| `key` | First 20 hex digits of SHA-1 of `path|size|mtime`; also the thumbnail name |
| `thumb` | Thumbnail path |
| `w`, `h` | Size after EXIF rotation |
| `portrait` | `h > w`; a monitor shows only pictures of its own orientation |
| `hue`, `hue_cov` | Dominant hue sector (`-1` grey, `0`…`11`) and its share |
| `favorite` | From the sidecar, or from `favorites.json` when the folder is read-only |
| `title`, `description`, `keywords`, `tags`, `style`, `source` | From the sidecar |
| `search` | Lower-case text that word search matches against |
| `missing` | Present and `true` when the folder was unreachable during the last scan (unmounted disk, unreadable subfolder). Such entries and their thumbnails are kept but not shown |

Supported image types: `.jpg .jpeg .png .webp .bmp .avif .jxl` (as far as the installed Pillow can decode them). Pictures over 400 megapixels are skipped. File names that are not valid UTF-8 are skipped with a message.
