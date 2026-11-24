# Translations

The interface is written in English in the code; translations live in `translations/<lang>.json`, one file per language: `de es fr it ja ko nl pl pt_BR ru tr uk zh_CN`.

## Format

The DMS plugin format, keyed by **context first, then the English text**:

```json
{
  "Strip": { "Strip": "Bandes" },
  "ratio": { "Any": "Tous", "16:9 and 16:10": "16:9 et 16:10" },
  "resolution": { "Any": "Toutes" }
}
```

- Most strings have no special context, so the context equals the text itself.
- A context is used when the same English word needs different translations (French "Any" for a ratio versus a resolution). In QML these strings are written as `shell.trc("Any", "ratio")`; in a `Choice` list the context is its `ctx:` property.
- `%1`, `%2` are placeholders and must stay in the translation.
- In plugin mode DMS looks up via `I18n.trFor("skindancer", text, context)` in this order: `table[context][text]`, `table[text][text]`, the same text in any context of the plugin's table, then DMS's own catalogs. The plugin passes no context when it equals the text. Standalone mode reads the same files itself but does only the first two steps, so a missing entry can be translated in plugin mode and stay English standalone.

## Where strings come from

`tools/i18n_check.py` collects every translatable string from the QML:

- `tr("…")`, `trc("…", "context")` and `I18n.trFor("skindancer", "…")`;
- `Choice { label: …; ctx: …; options: [[value, "Label"], …] }` blocks;
- help rows in `Help.qml` (`[key, text]`; a third element `true` marks a command that is not translated, a string `"own"` or `"dms"` limits the row to one mode);
- desktop menu items in `Oboi.qml` and view names in `Picker.qml`.

```bash
python3 tools/i18n_check.py            # print the list of [text, context] keys as JSON
python3 tools/i18n_check.py --check    # every translation file: missing, extra, empty, broken %N
```

Run `--check` after changing any visible string. It exits with 1 on errors.

## Adding a language

1. Copy an existing file to `translations/<code>.json` (code as DMS uses it, e.g. `pt_BR`, `zh_CN`).
2. Translate every value; keep keys, contexts and `%N` as they are.
3. Add the code to `langFiles` in `Oboi.qml`, to the language list in the settings panel (`Picker.qml`, standalone only), and the language's own name to `KEEP` in `tools/i18n_check.py` (language names are not translated; without this `--check` fails in every file).
4. Run `python3 tools/i18n_check.py --check`.
5. Optionally translate `README.md` to `README.<code>.md` and add it to the language bar of every README.

Please have the translation read by a native speaker. Language names (`English`, `Русский`, …) and technical labels (`SFW`, `4K`) are not translated.
