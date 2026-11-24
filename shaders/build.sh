#!/usr/bin/env bash
# Собирает переходы в .qsb: common.glsl + <имя>.body → <имя>.frag.qsb.
# Готовые .qsb лежат в репозитории, на машинах qsb не нужен.
set -e
cd "$(dirname "$0")"
QSB=${QSB:-/usr/lib/qt6/bin/qsb}
T=$(mktemp -d)                      # своя временная папка, а не предсказуемое имя в /tmp
trap 'rm -rf "$T"' EXIT
for b in *.body; do
    n=${b%.body}
    cat common.glsl "$b" > "$T/$n.frag"
    "$QSB" --qt6 -o "$n.frag.qsb" "$T/$n.frag"
    echo "собран $n.frag.qsb"
done
