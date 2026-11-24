#!/bin/bash
# Внутри виртуалки: прогон Skindancer через IPC со снимками, замерами и логами.
#   test-plugin.sh <метка>   результат в ~/oboi-test/<метка>/
set -u
OUT=~/oboi-test/${1:-run}; mkdir -p "$OUT"; : > "$OUT/steps.log"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=$(ls "$XDG_RUNTIME_DIR" | grep -m1 -E '^wayland-[0-9]+$')
export NIRI_SOCKET=$(ls "$XDG_RUNTIME_DIR"/niri*.sock 2>/dev/null | head -1)
since=$(date '+%Y-%m-%d %H:%M:%S')
log() { echo "== $*" | tee -a "$OUT/steps.log"; }
run() { echo "\$ $*" >> "$OUT/steps.log"; "$@" >> "$OUT/steps.log" 2>&1; }
ipc() { echo "\$ ipc $*" >> "$OUT/steps.log"; timeout 10 dms ipc call skindancer "$@" >> "$OUT/steps.log" 2>&1 || log "ipc $* вернул $?"; }
shot() { grim "$OUT/$1.png" 2>>"$OUT/steps.log" || log "нет снимка $1"; }
qspid() { pgrep -x quickshell || pgrep -x qs || pgrep -f 'quickshell|/qs ' | head -1; }
cpu() { local p; p=$(qspid | head -1); [ -n "$p" ] && top -b -d 1 -n 4 -p "$p" | awk -v t="$1" '/^ *[0-9]/{c=c" "$9; m=$6} END{print "ЦП оболочки, " t ":" c " %, RSS " m}' | tee -a "$OUT/steps.log"; }

log "версии"
run dms version; run qs --version; run niri --version; run python3 --version
run python3 -c "import PIL; print('Pillow', PIL.__version__)"; run uname -r
run sh -c "glxinfo -B 2>/dev/null | grep -E 'renderer|version string'"
run sh -c "dms plugins list 2>&1 | grep -i skindancer"
ls ~/.config/dms/plugins/skindancer/bin/oboi-helper >/dev/null 2>&1 && log "помощники: собранный oboi-helper" || log "помощники: python3"

log "индекс с нуля"
rm -rf /tmp/oboi-idx
/usr/bin/time -f "индекс: %e с, %M КБ" ~/.config/dms/plugins/skindancer/bin/oboi-index --quiet --dir ~/Pictures/Wallpapers \
    --out /tmp/oboi-idx/index.json --thumbs /tmp/oboi-idx/thumbs 2>&1 | tail -3 | tee -a "$OUT/steps.log"

WALL=$(ls ~/Pictures/Wallpapers/* | head -1)
run dms ipc call wallpaper set "$WALL"; sleep 3; shot 00-desktop
cpu "стол без ленты"

log "лента"
ipc picker; sleep 5; shot 01-picker; cpu "лента открыта"
ipc next; ipc next; sleep 1.5; shot 02-next
ipc view wall; sleep 2; shot 03-wall
ipc view depth; sleep 2; shot 04-depth
ipc view slices; sleep 1
ipc settings; sleep 1.5; shot 05-settings; ipc settings
ipc help; sleep 1.5; shot 06-help; ipc closeHelp; sleep 0.5
ipc source wallhaven; ipc find lighthouse; sleep 25; shot 07-wallhaven; ipc source local; sleep 1

log "применить обои"
before=$(dms ipc call wallpaper get 2>&1)
ipc next; ipc apply; sleep 1; cpu "переход"; sleep 3; shot 08-applied
after=$(dms ipc call wallpaper get 2>&1)
log "обои: $before -> $after"; [ "$before" != "$after" ] && log "обои сменились" || log "ОБОИ НЕ СМЕНИЛИСЬ"
ipc close; sleep 1

log "журнал DMS"
journalctl --user -u dms --since "$since" --no-pager > "$OUT/dms.log"
grep -inE "oboi|Picker|Choice|Card\.qml|Slant|Help\.qml|qsb|shader|error|ReferenceError|TypeError" "$OUT/dms.log" \
    | grep -v "folder doesnt exist" | head -60 | tee -a "$OUT/steps.log"
log "готово: $OUT"
