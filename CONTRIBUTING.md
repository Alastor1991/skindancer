# Contributing to Skindancer

Thank you for wanting to help. Bug reports, translations, fixes and ideas are all welcome, in any language.

## Before you start

- **The maintainer's English is weak.** He reads and answers through a translator, so short, plain sentences help a lot. Writing in your own language is fine too.
- **How the code was made.** Skindancer was written by Claude (Anthropic's AI) in Claude Code, directed and tested by the maintainer. Code comments are in **Russian**. They explain the "why" of non-obvious places; a translator handles them well. New comments may be in English.
- **Names.** The old project name Oboi survives in file names, cache folders and the `.oboi/` sidecar folder. Do not rename these: users' caches and libraries depend on them. Everything user-facing is `skindancer`.
- Read [docs/README.md](docs/README.md) for how things fit together.

## Reporting a bug

Please include:

- distribution and version, compositor, DMS version (`dms version`), Quickshell version (`qs --version`);
- whether you use the prebuilt `oboi-helper` or system Python;
- what you did, what happened, what you expected;
- the DMS log around the problem: `journalctl --user -u dms --since "-10 min" | grep -iE "skindancer|oboi|error"`;
- for helper problems, the output of `~/.config/dms/plugins/skindancer/bin/oboi-index --dir <folder> --out /tmp/i.json --thumbs /tmp/th` (without `--quiet`).

## Changing code

- Keep changes small and focused; explain the reason in the commit message.
- After changing visible text, update every file in `translations/` (at least copy the English text) and run `python3 tools/i18n_check.py --check`. See [docs/translations.md](docs/translations.md).
- Python helpers must keep working on Python 3.10+ and must not need anything beyond Pillow (and the optional semantic-search packages).
- Launchers in `bin/` are POSIX `sh`: they must work with dash and BusyBox ash, with GNU coreutils or BusyBox tools (`readlink -f`, `stat -c`, `find -mmin` are fine), and must not rely on `bash` or `flock`.
- Do not commit `bin/oboi-helper`, caches or test output.
- If you touch the picker, test the three views, search, the wallhaven tab, settings and applying a wallpaper, in plugin mode, ideally on two compositors. [docs/testing.md](docs/testing.md) describes the virtual machine harness.

## Translations

New languages and fixes to existing ones are very welcome. A translation that a native speaker has read is worth more than a complete one that nobody has.

## License

By contributing you agree that your contribution is licensed under GPL-3.0-or-later, like the rest of the project.
