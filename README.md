# Oboi

A wallpaper picker for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell): a full-screen overlay with search, favorites, three views, five shader transitions and wallhaven.cc search right inside it.

<p align="center"><img src="../../docs/preview/transitions.webp" width="960" alt="Shader transitions"></p>

## Features

- **Three views.** A strip of slanted cards that stretch like jelly, a wall (grid) you walk cell by cell with the arrow keys, and a depth view where cards recede into the distance.
- **Five transitions.** Grow, iris, dissolve, melt and ink, written as GLSL shaders. Or none, and DMS does its own.
- **Search.** By file name, title, description and tags; optional semantic search with a local SigLIP2 model (English queries like `desert` or `rain` find matching images even without tags).
- **Favorites and colors.** Star a wallpaper with Ctrl+D, filter by twelve hues or by favorites.
- **wallhaven.cc tab.** Search online with filters for resolution, aspect ratio, sorting, categories and purity; Enter saves the image into your wallpaper folder with its tags.
- **13 languages.** English, Русский, Deutsch, Español, Français, Italiano, Português (BR), Nederlands, Polski, Українська, Türkçe, 日本語, 한국어, 简体中文. The language follows DMS.

## Install

```bash
git clone <this repository>
mkdir -p ~/.config/dms/plugins
ln -s "$PWD/like_dali/oboi/shell" ~/.config/dms/plugins/oboi
```

Then enable **Oboi** in DMS Settings → Plugins.

Helpers (indexing, thumbnails, wallhaven, semantic search) come in one of two ways:

- **Prebuilt binary, nothing else to install.** Put `oboi-helper` from the GitHub release into `bin/` (`chmod +x`). It bundles Python, Pillow, numpy, onnxruntime and tokenizers, runs on any x86_64 Linux with glibc 2.28+, and unpacks once into `~/.cache/oboi/`. Build it yourself with `tools/build-helper.sh` (needs podman or docker).
- **System Python.** `python3` and `python-pillow`; for semantic search also `python-onnxruntime-cpu`, `python-tokenizers`, `python-numpy`.

Semantic search also needs the SigLIP2 model files in `~/.local/share/oboi/models/siglip2` (see `bin/oboi_semantic.py`). Without them the picker searches by words.

## Use

- Open the picker: `dms ipc call oboi picker` (bind it to a key in niri or Hyprland), or turn on **Right-click menu on the desktop** in the plugin settings. That replaces the DMS desktop menu with Oboi's; turning it off brings the DMS menu back.
- ← → browse, ↑ ↓ rows in grids, Enter sets the wallpaper, Ctrl+D favorite, Ctrl+1 2 3 views, Ctrl+4 wallhaven, F1 help, Esc close. The gear opens settings.

Other IPC methods: `random`, `next`, `prev`, `apply`, `find <words>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <name>`, `help`, `close`.

## What it writes

- `~/.cache/oboi/`: the index, thumbnails and semantic vectors (per machine).
- `<wallpaper folder>/.oboi/<file>.json`: favorites and, for images saved from wallhaven, their tags and source. These small files travel with the folder if you sync it.
- Network: only the wallhaven tab talks to wallhaven.cc, and only while it is open. SFW and 4K by default; NSFW needs your own wallhaven API key in the plugin settings.

## Settings

The plugin page in DMS settings has the wallpaper folder (empty means the folder of the current wallpaper), the right-click menu toggle and the wallhaven API key. Everything else (transition, start view, bounce, captions, hints, semantic search, the wallhaven tab and its filters) is set inside the picker.

## Standalone

The same code also runs without the plugin system as a Quickshell config (`qs -c oboi`, entry `shell.qml`); that is how the `like_dali` desktop theme in this repository uses it.

## License

GPL-3.0-or-later, see [LICENSE](LICENSE). Icons and shaders are original to this project.
