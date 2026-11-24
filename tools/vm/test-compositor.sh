#!/usr/bin/env bash
# Внутри виртуалки, в живом сеансе: проверка Skindancer на текущем композиторе.
#   test-compositor.sh <метка>      результат в ~/oboi-test/<метка>/
# Правый клик «Обоев» в настройках включён нарочно: на labwc, Sway, Scroll и KWin плагин
# не должен его ставить (там клики по столу у композитора), на niri и Hyprland должен.
# Мышь через ydotool (uinput, демон ydotoold), клавиатура через wtype.
set -u
fail=0
OUT=~/oboi-test/${1:-comp}; rm -rf "$OUT"; mkdir -p "$OUT"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=$(ls "$XDG_RUNTIME_DIR" | grep -m1 -E '^wayland-[0-9]+$')
export YDOTOOL_SOCKET=/tmp/.ydotool_socket
# демон ydotoold (uinput) нужен мыши; в Arch у пакета нет системной службы
pgrep -x ydotoold >/dev/null || { sudo ydotoold --socket-path="$YDOTOOL_SOCKET" --socket-own="$(id -u):$(id -g)" >/dev/null 2>&1 & sleep 2; }
log() { echo "== $*" | tee -a "$OUT/steps.log"; }
shot() { grim "$OUT/$1.png" 2>>"$OUT/steps.log" || { log "нет снимка $1"; fail=1; }; }
ipc() { timeout 10 dms ipc call skindancer "$@" >> "$OUT/steps.log" 2>&1 || { log "ipc $* вернул $?"; fail=1; }; }
click() { ydotool mousemove --absolute -x "$1" -y "$2" >/dev/null 2>&1 && sleep 0.3 && ydotool click "$3" >/dev/null 2>&1 || { log "ydotool не сработал"; fail=1; }; }
menu() { python3 -c "
import json,os
for p in ('~/.config/dms/settings.json','~/.config/DankMaterialShell/settings.json'):
    p=os.path.expanduser(p)
    if os.path.exists(p): print(json.load(open(p)).get('desktopContextMenu','auto')); break" 2>/dev/null; }
pid=$(python3 -c "import json,os;d=json.load(open(os.path.expanduser('~/.config/dms/plugin_settings.json')));print(d.get('skindancer',{}).get('dmsMenuBefore',''))" 2>/dev/null)

log "композитор: ${XDG_CURRENT_DESKTOP:-?}, DMS $(dms version 2>&1 | head -1)"
log "меню стола DMS: $(menu), плагин сохранил прежнее значение: '${pid}'"
sleep 2; shot 00-desktop
log "правый клик по пустому столу"
click 960 900 0xC1; sleep 1.5; shot 01-rightclick
wtype -k Escape; sleep 0.5

log "лента по IPC"
ipc picker; sleep 4; shot 02-picker
wtype lighthouse; sleep 1.5; shot 03-typed
wtype -k Escape; sleep 0.3                 # первый Esc стирает поиск
wtype -k Right -k Right; sleep 1; shot 04-arrows
# обои того экрана, где лента: при режиме по мониторам get отвечает ошибкой, тогда getFor
wp() { r=$(dms ipc call wallpaper get 2>&1); case "$r" in ERROR*) dms ipc call wallpaper getFor "${OUTPUT:-Virtual-1}" 2>&1;; *) echo "$r";; esac; }   # OUTPUT: проверяемый монитор
before=$(wp)
wtype -k Return; sleep 4; shot 05-applied
after=$(wp)
[ "$before" != "$after" ] && log "обои сменились клавишей Enter" || { log "ОБОИ НЕ СМЕНИЛИСЬ"; fail=1; }
ipc picker; sleep 3; wtype -k Escape; sleep 1; shot 06-closed
log "журнал DMS"
journalctl --user -u dms --since "-5 min" --no-pager 2>/dev/null | grep -iE "skindancer|oboi|error" | grep -viE "folder doesnt|textinput" | tail -20 | tee -a "$OUT/steps.log"
[ $fail -eq 0 ] || log "ЕСТЬ ОШИБКИ"
log "готово"
exit $fail
