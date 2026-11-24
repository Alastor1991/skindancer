#!/usr/bin/env bash
# Собирает помощников «Обоев» в один исполняемый файл oboi/shell/bin/oboi-helper,
# как бинарник на Go: Python и все библиотеки внутри, на машине пользователя ничего ставить не надо.
#
#   tools/build-helper.sh            собрать (нужен podman или docker)
#
# Сборка идёт в контейнере manylinux_2_28 (glibc 2.28, AlmaLinux 8): готовый файл запускается
# на любом x86_64 Linux с glibc 2.28 и новее (Debian 10+, Ubuntu 20.04+, Fedora, Arch, openSUSE).
# Собирать прямо в CachyOS нельзя: её Python собран под x86-64-v3, а glibc там 2.44,
# и файл не запустится на старых процессорах и дистрибутивах.
#
# Внутри Nuitka onefile. При первом запуске файл распаковывается в ~/.cache/oboi/helper-<хэш>
# и дальше стартует оттуда без распаковки; новая сборка получает новый хэш и новую папку.
set -euo pipefail
R=$(cd "$(dirname "$0")/.." && pwd)
BIN=$R/bin
IMAGE=quay.io/pypa/manylinux_2_28_x86_64
PY=/opt/python/cp313-cp313/bin/python
ENGINE=$(command -v podman || command -v docker) || { echo "нужен podman или docker" >&2; exit 1; }

# хэш исходников и версий библиотек: по нему отличаются папки распаковки разных сборок
HASH=$(cat "$BIN"/oboi_*.py "$R/tools/helper-requirements.txt" | sha256sum | cut -c1-12)
WORK=$R/build/helper
mkdir -p "$WORK"

"$ENGINE" run --rm \
    -v "$BIN:/src:ro,z" -v "$R/tools/helper-requirements.txt:/req.txt:ro,z" -v "$WORK:/out:Z" \
    -e HASH="$HASH" "$IMAGE" bash -euc '
        (cd /opt/_internal && tar xf static-libs-for-embedding-only.tar.xz)
        '"$PY"' -m pip install -q --root-user-action=ignore -r /req.txt
        cd /out
        '"$PY"' -m nuitka --onefile --assume-yes-for-downloads --remove-output \
            --onefile-tempdir-spec="{CACHE_DIR}/oboi/helper-$HASH" \
            --include-module=oboi_index --include-module=oboi_fetch --include-module=oboi_semantic \
            --nofollow-import-to=numpy.tests --nofollow-import-to=PIL.ImageQt --nofollow-import-to=tkinter \
            --output-filename=oboi-helper --output-dir=/out /src/oboi_helper.py
    '
install -m 755 "$WORK/oboi-helper" "$BIN/oboi-helper"
ls -lh "$BIN/oboi-helper"
echo "готово: $BIN/oboi-helper (распаковка в ~/.cache/oboi/helper-$HASH)"
