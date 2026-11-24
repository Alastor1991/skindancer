# Building and releasing

Nothing needs to be built to run Skindancer from a git clone: the QML is interpreted, the shaders are committed as `.qsb`, the helpers run with system Python. Building is only needed for the prebuilt helper and after changing a shader.

## The prebuilt helper `oboi-helper`

```bash
tools/build-helper.sh        # needs podman or docker
```

- Builds in the `quay.io/pypa/manylinux_2_28_x86_64` container (glibc 2.28, AlmaLinux 8) with CPython 3.13, so the result runs on any x86_64 Linux with glibc 2.28 or newer. Do not build it on the host: a distribution such as CachyOS compiles Python for x86-64-v3 and has a new glibc, and the file would not start on older CPUs or distributions.
- Libraries come from PyPI with pinned versions in `tools/helper-requirements.txt` (Nuitka, zstandard for onefile compression, Pillow, numpy, onnxruntime, tokenizers). Check a new version before bumping it.
- Nuitka `--onefile` with `--onefile-tempdir-spec={CACHE_DIR}/oboi/helper-<hash>`: the bundle unpacks once per version. `<hash>` is computed from the module sources and the requirements file, so a new build gets a new folder.
- The output is `bin/oboi-helper` (about 41 MB; ignored by git).
- Entry point `bin/oboi_helper.py`: `oboi-helper index|fetch|semantic …` and `oboi-helper where` (prints its unpack folder, used by the launchers).

## Shaders

Transitions are fragment shaders compiled with Qt's `qsb`:

```bash
shaders/build.sh             # QSB=/path/to/qsb to override /usr/lib/qt6/bin/qsb
```

Each `shaders/<name>.body` is appended to `shaders/common.glsl` and compiled to `<name>.frag.qsb` with `qsb --qt6` (SPIR-V 100, GLSL 100es/120/150, HLSL 50, MSL 12). The committed files are QSB format 9, which Qt 6.6 and newer read. `build.sh` does not pin the format: a much newer `qsb` could write a format older Qt cannot read, so check with `qsb --dump` before committing. Commit the `.qsb` files.

To add a transition: write `<name>.body`, build, add the name to `kinds` in `Picker.qml` and to the transition options in the settings panel, to [configuration.md](configuration.md) and [ipc.md](ipc.md), and add the label to the translations. Its duration is set per kind in `Picker.qml` (1.6 s, melt 1.9 s).

## CI and releases

`.github/workflows/helper.yml` runs `tools/build-helper.sh` on `ubuntu-24.04` for every tag `v*` (and on manual dispatch), checks `oboi-helper index --help` and `fetch --help`, and uploads `oboi-helper` and `oboi-helper.sha256` as the workflow artifact `oboi-helper-x86_64`. For a tag it also uploads them to the GitHub release of that tag (creating it if needed); a manual run does not touch releases.

Releasing a version:

1. Update `version` in `plugin.json`.
2. If the NixOS snippet in the READMEs names a tag, update it.
3. Commit, then `git tag -a vX.Y.Z -m "Skindancer X.Y.Z" && git push origin main vX.Y.Z`.
4. Wait for the workflow; check that the release has both files and is marked latest.

The README images and clips live in a separate pre-release called `media`, not in the git tree, because `dms plugins install` clones the whole repository. Upload them with an image content type (`image/webp`, `image/png`), otherwise GitHub's image proxy may refuse to show them.
