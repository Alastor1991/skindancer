#!/usr/bin/env bash
# Arch: Sway и labwc рядом с Hyprland для живой проверки (tools/vm/test-compositor.sh).
# Запускать после arch.sh и session.sh. Композитор при входе выбирает ~/.session: hyprland, sway или labwc.
# DMS на Sway и labwc требует graphical-session.target, а эти композиторы его не поднимают:
# по документации DMS цель заводится вручную (здесь wlr-session.target).
set -euxo pipefail
sudo pacman -S --noconfirm --needed sway labwc swaybg ydotool wtype
mkdir -p ~/.config/systemd/user ~/.config/sway ~/.config/labwc
cat > ~/.config/systemd/user/wlr-session.target <<'C'
[Unit]
Description=Sway or labwc session for DMS
BindsTo=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target
C
systemctl --user daemon-reload
systemctl --user add-wants wlr-session.target dms
cat > ~/.config/sway/config <<'C'
include /etc/sway/config
bar bar-0 mode invisible
exec "systemctl --user import-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP DISPLAY; systemctl --user start wlr-session.target"
C
cat > ~/.config/labwc/autostart <<'C'
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY
systemctl --user start wlr-session.target &
C
# вход на tty1: композитор из ~/.session
python3 - <<'P'
import os, re
p = os.path.expanduser("~/.bash_profile"); s = open(p).read()
s = re.sub(r'if \[ "\$\(tty\)" = /dev/tty1 \].*\n', '', s)
s += '''if [ "$(tty)" = /dev/tty1 ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  case "$(cat ~/.session 2>/dev/null)" in
    sway) export XDG_CURRENT_DESKTOP=sway; exec sway >/tmp/session.log 2>&1 ;;
    labwc) export XDG_CURRENT_DESKTOP=labwc:wlroots; exec labwc >/tmp/session.log 2>&1 ;;
    *) exec $(command -v start-hyprland || command -v Hyprland) >/tmp/session.log 2>&1 ;;
  esac
fi
'''
open(p, "w").write(s)
P
# ydotool без системной службы: демон запускает test-compositor.sh через sudo
