# Configuration

## Where settings are stored

| Mode | Storage | Who writes it |
|---|---|---|
| Plugin | `~/.config/dms/plugin_settings.json`, object `skindancer` | DMS: the plugin page in DMS settings, the picker's settings panel (through `pluginService.savePluginData`), IPC `set` |
| Standalone | `~/.config/oboi/config.json` (`$XDG_CONFIG_HOME/oboi/config.json`) | The picker's settings panel, IPC `set`, or you by hand |

In standalone mode the picker does not write `config.json` until it has read it once, and never writes over a file it could not parse: it shows an error in the settings panel instead.

## Keys

| Key | Type | Default | Meaning |
|---|---|---|---|
| `folder` | string | empty | **Plugin only.** Wallpaper folder. Empty: the folder of the current wallpaper of the target monitor (when its path starts with `/`) plus `<Pictures>/Wallpapers`; with a colour or no wallpaper, `<Pictures>` plus `<Pictures>/Wallpapers` |
| `dirs` | array of strings | `<Pictures>`, `<Pictures>/Wallpapers` | **Standalone only.** Wallpaper folders, `~` allowed; pictures saved from wallhaven go to the first one. Scanned recursively, a picture reachable from two folders is listed once. Skipped: hidden folders, folders named `screenshots`, `скриншоты` or `снимки экрана` (any case), files starting with `.`, ending in `.part` or containing `.sync-conflict-` |
| `catcher` | bool | `false` | **Plugin only.** Right-click menu on the desktop. Ignored on labwc, Sway, Scroll and KWin |
| `wallhaven_apikey` | string | empty | wallhaven.cc API key, needed only for NSFW results |
| `language` | string | `auto` | **Standalone only.** `auto` or one of `en ru de es fr it pt_BR nl pl uk tr ja ko zh_CN`. The plugin follows the DMS language |
| `transition` | string | `random` | `random`, `grow`, `iris`, `dissolve`, `melt`, `ink`, `none` |
| `view` | string | `last` | View on open: `last` (the last view used since the shell started; after a restart that is the strip), `slices` (strip), `wall`, `depth` |
| `jelly` | bool | `true` | Jelly bounce of cards |
| `captions` | bool | `true` | Title, description and tags under the selected card |
| `hints` | bool | `true` | Key hints at the bottom |
| `semantic` | bool | `true` | Search by meaning (only works when the model and its Python packages are present) |
| `wallhaven` | bool | `true` | Show the wallhaven tab |
| `wh` | object | see below | wallhaven filters |

`wh` fields (all strings, same values as the wallhaven API):

| Field | Default | Values |
|---|---|---|
| `atleast` | `3840x2160` | minimum resolution, empty for any |
| `ratios` | `16x9,16x10` | comma-separated, empty for any |
| `categories` | `111` | general / anime / people as bits, e.g. `010` anime only |
| `purity` | `100` | SFW / sketchy / NSFW as bits; NSFW needs an API key |
| `sorting` | empty | empty (relevance for a query, top of the last year for an empty query), `toplist` (last year), `date_added`, `favorites`, `random` |

Example standalone `config.json`:

```json
{
  "dirs": ["~/Pictures/Wallpapers"],
  "transition": "melt",
  "view": "wall",
  "wh": { "atleast": "2560x1440", "ratios": "", "categories": "100", "purity": "100", "sorting": "toplist" }
}
```

In plugin mode DMS also stores `dmsMenuBefore`: the value of the DMS desktop-menu setting before the plugin switched it off, used to restore it.

In standalone mode the settings panel and IPC `set` rewrite the whole `config.json` (two-space indent). While the file cannot be parsed, changes are not saved.

## Environment variables

| Variable | Used by | Meaning |
|---|---|---|
| `OBOI_CACHE` | `oboi-index`, `oboi-semantic` | Cache folder for the index, thumbnails and vectors. The core keeps the plugin in `~/.cache/oboi/dms` and standalone in `~/.cache/oboi`: it passes `--out`/`--thumbs` to `oboi-index` and sets `OBOI_CACHE` for `oboi-semantic`. `oboi-index` uses the variable only for its defaults |
| `OBOI_WALLHAVEN_KEY` | `oboi-fetch` | API key. The plugin always sets it, even empty, so a standalone key in `config.json` is never mixed in |
| `OBOI_MODEL` | `oboi-semantic`, `tools/get-model.sh` | Folder with the SigLIP2 model, default `$XDG_DATA_HOME/oboi/models/siglip2` (`~/.local/share/…`) |
| `XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_STATE_HOME`, `XDG_DATA_HOME` | all | Standard base folders; empty values fall back to the defaults |
| `XDG_CURRENT_DESKTOP` | core, standalone | Decides whether the desktop right-click catcher is created |
| `SSL_CERT_FILE` | `oboi-fetch` | If unset, the prebuilt helper looks for the system CA bundle in the usual places of Debian, Fedora, openSUSE, Arch and Alpine |
