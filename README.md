<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, a surreal wallpaper picker for DMS"></p>

<p align="center">
<b>English</b> ·
<a href="README.ru.md">Русский</a> ·
<a href="README.de.md">Deutsch</a> ·
<a href="README.es.md">Español</a> ·
<a href="README.fr.md">Français</a> ·
<a href="README.it.md">Italiano</a> ·
<a href="README.pt_BR.md">Português (BR)</a> ·
<a href="README.nl.md">Nederlands</a> ·
<a href="README.pl.md">Polski</a> ·
<a href="README.uk.md">Українська</a> ·
<a href="README.tr.md">Türkçe</a> ·
<a href="README.ja.md">日本語</a> ·
<a href="README.ko.md">한국어</a> ·
<a href="README.zh_CN.md">简体中文</a>
</p>

# Skindancer

A wallpaper picker for [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) in the spirit of Salvador Dalí: a full-screen overlay with search, favorites, three views, shader transitions and wallhaven.cc search built in. It is a DMS plugin and works out of the box on niri, Hyprland and the other compositors DMS supports.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Shader transitions: grow, melt, ink and iris"></p>

**The wallpaper doesn't just change, it transforms.** A card grows out of the strip to fill the screen, the old picture melts down in drips, ink spills across it, or a pupil opens onto the next one. Five transitions (grow, iris, dissolve, melt, ink), picked at random or pinned in settings, or none at all.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Strip view: slanted cards that wobble like jelly"></p>

**A strip of slanted cards with a jelly bounce.** Flick through and the cards stretch, overshoot and settle.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="Search narrows the strip as you type"></p>

**Search.** By file name, title, description and tags. Titles and tags can live in a small sidecar file next to the picture (`.oboi/<name>.json`), and pictures saved from wallhaven get them automatically. Optionally, a local SigLIP2 model adds search by meaning: English words like `desert` or `rain` find matching pictures even without tags.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Wall view: a grid you hop across"></p>

**Wall.** The whole library at a glance; the arrow keys hop from cell to cell.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Depth view: cards stacked into the distance"></p>

**Depth.** Cards recede into the scene like a deck of postcards.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: search, filter, save, then apply"></p>

**wallhaven built in.** Search wallhaven.cc right from the picker with filters for resolution, aspect ratio, sorting, categories and purity. Enter saves the picture into your wallpaper folder with its tags, and it shows up in your library.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Settings: drop-down lists that unroll like a soft sheet with drips"></p>

**Settings right in the picker.** Every option is a drop-down that unrolls like a soft sheet and drips at the edge. The interface speaks 13 languages and follows the DMS language.

## Install

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Then turn on **Skindancer** in DMS Settings → Plugins. (If you set `XDG_CONFIG_HOME`, the folder is `$XDG_CONFIG_HOME/dms/plugins`.)

The picker needs small helper programs for indexing, thumbnails and wallhaven. There are two ways to provide them:

- **Prebuilt binary, nothing else to install.** Download `oboi-helper` from the [latest release](https://github.com/Alastor1991/skindancer/releases/latest) into the plugin's `bin` folder and make it executable:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  It bundles Python, Pillow, numpy, onnxruntime and tokenizers and runs on any x86_64 Linux with glibc 2.28 or newer. The release also has `oboi-helper.sha256`. You can build it yourself with `tools/build-helper.sh` (needs podman or docker).
- **System Python.** `python3` and Pillow (`python-pillow` on Arch, `python3-pil` on Debian and Ubuntu, `python3-pillow` on Fedora, `python313-Pillow` on openSUSE). For search by meaning also onnxruntime, tokenizers and numpy.

Search by meaning is optional and needs the model files (about 410 MB): run `tools/get-model.sh`. Without them the picker searches by words.

## Use

- **Open the picker:** `dms ipc call skindancer picker`. Bind it to a key in your compositor, for example in niri: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Or turn on **Right-click menu on the desktop** in the plugin settings: this replaces the DMS desktop menu with Skindancer's, and turning it off brings the DMS menu back. On labwc, Sway, Scroll and KWin the compositor keeps desktop clicks for itself, so there (like DMS) the menu stays off and you use a key.
- **Keys:** ← → browse, ↑ ↓ move by rows in the grids, Enter sets the wallpaper, Ctrl+D adds to favorites, Ctrl+1 2 3 switch views, Ctrl+4 opens wallhaven, F1 help, Esc closes. The gear opens settings.
- **Other IPC commands:** `random`, `next`, `prev`, `apply`, `find <words>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <name>`, `help`, `close`.

The picker opens on the monitor that has focus and works with per-monitor wallpapers.

## Settings

The plugin page in DMS settings has the wallpaper folder (empty means the folder of the current wallpaper, or your Pictures folder), the right-click menu and the wallhaven API key. Everything else is set inside the picker: transition, start view, bounce, captions, key hints, search by meaning and the wallhaven tab with its filters.

## What it writes and when it goes online

- `~/.cache/oboi/dms/`: the index and thumbnails. Recreated if you delete it.
- `<wallpaper folder>/.oboi/<file>.json`: favorites and, for pictures saved from wallhaven, their tags and source. These small files travel with the folder if you sync it. If the folder is read-only, favorites go to `~/.local/state/oboi/favorites.json` instead.
- Network: only the wallhaven tab talks to wallhaven.cc, and only while it is open. SFW and 4K by default. NSFW needs your own wallhaven API key; the key is sent in a request header and never in the address.

## Tested on

Installed the way this README says, on clean virtual machines with DMS 2.1.2 set up by the official instructions: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 and openSUSE Tumbleweed on niri, and Arch Linux on Hyprland, each with system Python and with the prebuilt binary. Daily use is on CachyOS with niri. The test scripts are in `tools/vm/`.

Not tested yet: real NVIDIA and AMD cards (the virtual machines draw with virgl, so smoothness of the transitions could not be judged there), several physical monitors, NixOS, Gentoo and Void.

## Known limitations

- The API key field in DMS settings shows the key in plain text: DMS plugin settings have no hidden input yet.
- If you remove the plugin while its right-click menu is on, turn the DMS desktop menu back on in DMS settings (Desktop Widgets → General → Right-click menu).
- Without a GPU (Qt software rendering) the cards are plain rectangles and wallpapers change without a transition.
- Portrait pictures appear only on a portrait monitor.

## The name

Face Dancers are the shape-shifters of Frank Herbert's *Dune*: they put on any face. That is what this utility does to your desktop. In Russian the project is called «Лицедейка» (litsedeyka, "the face dancer" or "the actress"). The working name was Oboi (обои, Russian for "wallpaper"), and it is still visible in file and cache names.

## About this project

I'm Alex. I want to be honest about how Skindancer was made: I did not write its code. All of it was written by Claude, Anthropic's AI, in Claude Code. My part was to know what I wanted: a beautiful wallpaper picker that works out of the box on DMS and that I could share with other people. I described it, looked at every version, said "no, not like this" many times, decided what stays and what goes, and tested it on my own machines.

My English is not good. I will read issues and answer them through a translator, so please write simply, and forgive me if my answers sound strange. Issues and pull requests in any language are welcome.

## License

GPL-3.0-or-later, see [LICENSE](LICENSE). The icons and shaders were made for this project. The pictures in the preview belong to their authors and are not part of the project.
