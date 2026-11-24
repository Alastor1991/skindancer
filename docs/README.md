# Skindancer technical documentation

This folder is for people (and their coding agents) who want to understand, change or package Skindancer. If you only want to install and use it, the [main README](../README.md) is enough.

| Document | What is in it |
|---|---|
| [architecture.md](architecture.md) | How the pieces fit: the DMS daemon, the core, the picker window, the helpers, and who starts what |
| [ipc.md](ipc.md) | Every IPC command with its arguments, for the plugin and for standalone mode |
| [configuration.md](configuration.md) | All settings keys, where they are stored, environment variables |
| [files-and-formats.md](files-and-formats.md) | What lives on disk: caches, the index, thumbnails, sidecar files, favourites state |
| [helpers.md](helpers.md) | The three helper programs, their command lines and outputs, the prebuilt binary and how the launchers choose between it and Python |
| [building-and-releasing.md](building-and-releasing.md) | Building `oboi-helper`, shaders, CI, cutting a release |
| [translations.md](translations.md) | Translation file format, adding a language, the consistency check |
| [testing.md](testing.md) | The virtual machine test harness for other distributions and compositors |

A note on names: the project started as **Oboi** (обои, Russian for "wallpaper"). File names (`Oboi.qml`, `bin/oboi-*`), cache folders (`~/.cache/oboi`) and the sidecar folder (`.oboi/`) keep that name on purpose, so existing libraries and caches keep working. The plugin id, the IPC target and everything users see is **skindancer**. Code comments are in Russian; see [CONTRIBUTING.md](../CONTRIBUTING.md).
