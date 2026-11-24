# Architecture

Skindancer is QML that runs inside Quickshell, plus three small helper programs for the work QML is bad at (decoding images, HTTP, a neural network). It runs in two modes from the same code:

- **Plugin mode**: DMS loads it as a daemon plugin. This is what users install.
- **Standalone mode**: `qs -c oboi` runs it as its own Quickshell config next to DMS. It is kept for setups that do not use the plugin system.

## Files

| File | Role |
|---|---|
| `plugin.json` | DMS plugin manifest: id `skindancer`, type `daemon`, entry points below |
| `OboiDaemon.qml` | Plugin entry (`PluginComponent`). Reads the plugin settings, owns the DMS desktop-menu switch, creates the core with `hosted: true` and a `host` object |
| `OboiSettings.qml` | The plugin page in DMS Settings → Plugins (folder, right-click menu, wallhaven key) |
| `StartupCheck.qml` | Run by DMS when the plugin is enabled: passes if the prebuilt helper runs here or `python3` can import Pillow |
| `shell.qml` | Standalone entry: `ShellRoot { Oboi {} }` |
| `Oboi.qml` | The core (a non-visual `Scope`): settings, translations, the index, helper processes, which monitor an action targets, the IPC handler, the desktop right-click catcher and menu. Creates `Picker` and `Help` |
| `Picker.qml` | The full-screen picker window: three views, search, colour and favourite filters, the wallhaven tab, the settings panel, the transitions |
| `Card.qml`, `Slant.qml` | One slanted wallpaper card; `Slant` is the parallelogram shape used as mask and frame |
| `Choice.qml` | The drop-down list used in settings and wallhaven filters |
| `Help.qml` | The help overlay (F1) |
| `shaders/` | Transition shaders: `common.glsl` + `<name>.body` → `<name>.frag.qsb` (built files are committed) |
| `icons/` | SVG icons |
| `translations/` | UI translations in the DMS format, see [translations.md](translations.md) |
| `bin/` | Helpers and their launchers, see [helpers.md](helpers.md) |
| `tools/` | Build, translation check, model download, VM tests |

## Plugin mode: who talks to whom

```
DMS PluginService ── loads ──> OboiDaemon.qml
                                   │ cfg (plugin settings), hostCurrent (current wallpaper of the target monitor)
                                   │ host { setWallpaper, save, tr, focusedScreen }
                                   v
                               Oboi.qml (core) ── creates ──> Picker.qml, Help.qml, menu, catcher windows
                                   │
                                   ├─ Process: bin/oboi-index    (index + thumbnails, favourites)
                                   ├─ Process: bin/oboi-semantic ("serve" while the picker is in use, "index" after every scan)
                                   └─ Picker → Process: bin/oboi-fetch (wallhaven search and save)
```

- **Settings** come from DMS (`pluginService.loadPluginData`). Changes made inside the picker go back through `host.save` (`savePluginData`). DMS stores them in `~/.config/dms/plugin_settings.json` under `skindancer`.
- **Setting a wallpaper** goes through `host.setWallpaper(path, monitor)`: `SessionData.setMonitorWallpaper` with per-monitor wallpapers, otherwise `SessionData.setWallpaper`. It also clears DMS's folder cycling, the same as the DMS desktop menu does.
- **Translations** go through `I18n.trFor("skindancer", text, context)`, so the language follows DMS.
- **Which monitor:** `host.focusedScreen()` asks DMS (`CompositorService.getFocusedScreenName()`). On labwc and KWin DMS does not know it, so the IPC commands with `On` take an output name.
- **Desktop right-click:** with the setting on, the core creates a transparent window on the Background layer of every output and catches right clicks. The daemon switches DMS's own desktop menu off (and saves the previous value) so the two do not fight. On labwc, Sway, Scroll and KWin (`CompositorService.reservesDesktopInput`) the catcher is never created, as DMS does for its own menu.

## Standalone mode differences

- Settings live in `~/.config/oboi/config.json` (see [configuration.md](configuration.md)); the picker writes it directly.
- The wallpaper is set with `dms ipc call wallpaper set <path>`, or `setFor <output> <path>` when DMS has per-monitor wallpapers on.
- The current wallpaper is read with `dms ipc call wallpaper get` (or `getFor`).
- Translations are read from `translations/<lang>.json` by the core; the language comes from the `language` setting or `LC_ALL`/`LC_MESSAGES`/`LANG`.
- The IPC target is `oboi`: `qs -c oboi ipc call oboi picker`.
- The right-click catcher is on unless `XDG_CURRENT_DESKTOP` names labwc, Sway, Scroll or KDE/KWin. Standalone mode does not switch off the DMS desktop menu, so turn it off yourself (DMS Settings → Desktop Widgets → General → Right-click menu), or both menus react to a right click.
- "Focused monitor" is always the first monitor: standalone mode has no access to DMS's focus tracking.

## Life of the picker

1. **Open** (`openPicker(screen)`): the target monitor is set first, then a background re-index starts (new pictures get thumbnails), then the current wallpaper is taken from the host (plugin) or asked from DMS (standalone).
2. **Index → list:** when `oboi-index` finishes, the core reloads `index.json` and filters it: no entries of folders that went missing, and only pictures of the monitor's orientation (portrait pictures on a portrait monitor, landscape ones elsewhere). A scan requested while another runs is queued with its own command. After each scan `oboi-semantic index` computes vectors for new pictures in the background (and runs again if a newer index arrived meanwhile).
3. **Selection:** the picker tries to land on the current wallpaper. Until the user moves, it keeps trying while the index is still being built, and gives up ten seconds after the index has arrived. Jumps happen without the scroll animation, because the strip's cards change width while it scrolls and the strict highlight range would stop on a neighbour.
4. **Search:** every query word must match the start of a word in the item's `search` text: file name, title, style, description, keywords, tags, the sidecar `query`, `WxH` and `4k` for pictures 3840 px wide or more. Query words longer than four letters lose one final Russian vowel, `й` or `ь`, so «пустыня» finds «пустыне». If semantic search is on and the warm helper answers for the same query, similar pictures are added; word matches always rank first, then everything by score.
5. **Apply:** the target monitor is captured at that moment. With a transition, the overlay animates (grow: the card expands; shader kinds: `ShaderEffect` over the old and new image, 1.6 s, melt 1.9 s), the wallpaper is handed to DMS during the animation, and the overlay stays until DMS reports the new path (at most 4 s), then fades. A shader transition falls back to grow when there is no old image, the old wallpaper is a colour or the same picture, or the old image failed to load. The wallpaper is set directly, without animation, when the transition is `none`, under Qt software rendering, or when the new image fails to load for a shader transition.
6. **Close:** the picker fades on the same monitor; running wallhaven searches are cancelled. The semantic helper stays warm for three more minutes.

## Layers

| Window | Layer | Keyboard | Namespace |
|---|---|---|---|
| Picker | Overlay | exclusive while open; released during a transition and while help is shown | `oboi:picker` |
| Help | Overlay | exclusive while open | `oboi:help` |
| Desktop menu | Overlay | on demand | `oboi:menu` |
| Right-click catcher | Background | none | `oboi:desktop-input` |

The namespaces matter if you write compositor rules (blur, animations) for these surfaces.
