# Notes for coding agents

This file is for AI coding agents (Claude Code, Codex, Cursor and others) working on this repository. Humans may find it useful too.

## What this is

A DankMaterialShell (DMS) daemon plugin written in Quickshell QML (Qt 6.6+), with three Python helpers. Plugin id and IPC target: `skindancer`. Historical name Oboi is kept in file names, caches and the `.oboi/` sidecar folder on purpose; do not rename them.

Start with [docs/README.md](docs/README.md), then [docs/architecture.md](docs/architecture.md).

## Ground rules

- **Code comments are in Russian.** Keep existing ones; you may write new comments in English. Do not "translate" or remove comments as a side effect of another change.
- **User-visible strings** are English in code and translated in `translations/*.json` (DMS format: `{context: {text: translation}}`). Every new or changed string needs an entry in all 13 files; run `python3 tools/i18n_check.py --check` (it must report `ок` for every file).
- **No em dash (U+2014)** in any file, text or comment. Use other punctuation.
- **QML specifics that bite:**
  - `GraphicsInfo` is an attached property of `Item`s; reading it on a `PanelWindow` returns nothing.
  - Quickshell `Process`: assigning `running` breaks a binding to it; to restart a bound process, toggle the bound condition. A process that fails to start emits `runningChanged` but not `exited`. There is no `Process.NormalExit`.
  - The strip is a `ListView` with `StrictlyEnforceRange`: set the selection with the scroll animation off (`jumpTo`), or it stops on a neighbouring card.
  - Signal handler order on one property change is not guaranteed; capture state before you change the property that triggers others (see the search field's `onTextChanged`).
- **Launchers in `bin/` are POSIX sh** and must run under dash, BusyBox ash and on NixOS: no bash, no `flock`; only tool options that both GNU coreutils and BusyBox have. Read [docs/helpers.md](docs/helpers.md) before touching `helper-ready.sh`.
- **Helpers** must work with system Python 3.10+ and Pillow only (semantic search packages are optional), and also inside the Nuitka onefile build.
- **Never overwrite user data.** Sidecars in the user's wallpaper folder may be synced and edited by hand: read, change one field, write atomically. Never delete files you did not create (thumbnail cleanup only removes names recorded in the previous index).
- **Network** only from the wallhaven tab while the picker is open. The API key goes in a header and must never appear in URLs, logs or error messages.

## How to verify a change

- Syntax: `python3 -c "import ast,sys; [ast.parse(open(f).read()) for f in sys.argv[1:]]" bin/oboi_*.py`, `for f in bin/oboi-index bin/oboi-fetch bin/oboi-semantic bin/helper-ready.sh; do sh -n "$f"; done` (`sh -n` checks only its first argument; do not glob `bin/oboi-*`, it matches the 40 MB binary).
- Translations: `python3 tools/i18n_check.py --check`.
- Behaviour: run it in DMS (`ln -s "$PWD" ~/.config/dms/plugins/skindancer`, enable in DMS Settings → Plugins, `systemctl --user restart dms`) and drive it with IPC: `dms ipc call skindancer picker`, `next`, `apply`, `view wall`, `find <words>`, `close`. Screenshots with `grim`. Check `journalctl --user -u dms` for QML errors (`TypeError`, `ReferenceError`, `Unable to assign`).
- Other distributions and compositors: [docs/testing.md](docs/testing.md).

Do not claim a change works on a compositor or distribution you did not run it on.
