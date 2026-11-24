# IPC commands

Plugin mode: `dms ipc call skindancer <command> [arguments]`
Standalone mode: `qs -c oboi ipc call oboi <command> [arguments]`

Commands that act on the picker are meant for an open picker. `apply` and `source` are ignored while it is closed; the colour and favourite filters are reset every time the picker opens.

## Opening

| Command | Arguments | What it does |
|---|---|---|
| `picker` | | Open the picker on the focused monitor. DMS knows it on niri, Hyprland, Sway, Scroll, Miracle, mango and Umbriel; elsewhere, and always in standalone mode, the first monitor |
| `pickerOn` | `output` | Open it on a named output, e.g. `DP-1`. Use this on labwc and KWin, where DMS cannot tell which monitor has focus. An unknown name falls back to the focused monitor (same for the other `…On` commands) |
| `random` | | Set a random wallpaper on the focused monitor, without opening anything. Right after start, before the index has been read, it only starts indexing and sets nothing |
| `randomOn` | `output` | Same on a named output |
| `menuAt` | `x` `y` | Open the Skindancer desktop menu at a position on the focused monitor |
| `menuAtOn` | `output` `x` `y` | Same on a named output |
| `help` | | Show the help overlay on the focused monitor |
| `closeHelp` | | Hide it |
| `close` | | Close the menu and the picker. A transition already running is allowed to finish |

## Inside the picker

| Command | Arguments | What it does |
|---|---|---|
| `next`, `prev` | | Move the selection by one (in the wallhaven tab: one result) |
| `cell` | `dx` `dy` | Move by cells in the grid views, e.g. `cell 0 1` is one row down |
| `apply` | | Set the selected picture (in the wallhaven tab: save it, same as `save`) |
| `find` | `words` | Put text into the search field. An empty string clears it and returns to the card selected before the search |
| `favorite` | | Toggle the star on the selected picture |
| `favorites` | | Toggle "favourites only" |
| `hue` | `n` | Colour filter: `-2` none, `-1` greys, `0`…`11` hue sectors of 30° starting at red |
| `view` | `slices` \| `wall` \| `depth` | Switch view (`slices` is the strip) |
| `source` | `local` \| `wallhaven` | Switch tab. Ignored while the picker is closed (nothing goes to the network in the background) and, for `wallhaven`, when the tab is turned off in settings |
| `save` | | Save the selected wallhaven result into the wallpaper folder |
| `transition` | `random` \| `grow` \| `iris` \| `dissolve` \| `melt` \| `ink` \| `none` | Force a transition until the shell restarts (the saved setting is not changed) |
| `settings` | | Toggle the settings panel |

## Settings

| Command | Arguments | What it does |
|---|---|---|
| `set` | `key` `value` | Change a setting, as the settings panel does. `true` and `false` become booleans, a value starting with `[` or `{` is parsed as JSON (for `dirs` and `wh`), anything else stays a string. Keys are listed in [configuration.md](configuration.md). In plugin mode the value is stored in DMS plugin settings, but only the keys the plugin reads back take effect (`transition`, `semantic`, `jelly`, `hints`, `captions`, `wallhaven`, `view`, `wh`, `wallhaven_apikey`, `catcher`, `folder`); in standalone mode it goes to `config.json` |

Example key binding for niri:

```kdl
binds {
    Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }
    Mod+Shift+W { spawn "dms" "ipc" "call" "skindancer" "random"; }
}
```
