#!/bin/bash
# Общая часть для всех машин: автовход пользователя oboi на tty1 и запуск композитора с DMS.
# niri: niri-session (-l: иначе он перезапускает себя через login-shell и снова попадает сюда).
# Hyprland (если niri нет): start-hyprland или Hyprland, DMS через hyprland-session.target.
set -euxo pipefail
# экран входа (Ubuntu ставит GDM вместе с dms) занял бы tty1: вход здесь через автологин
sudo systemctl disable display-manager.service 2>/dev/null || true
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
printf '[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin oboi --noclear %%I $TERM\n' \
    | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf
if command -v niri-session >/dev/null; then
    START='exec niri-session -l >/tmp/session.log 2>&1'
    systemctl --user add-wants niri.service dms
    # подсказка niri с клавишами при старте висит поверх всего и мешает снимкам
    mkdir -p ~/.config/niri
    grep -q skip-at-startup ~/.config/niri/config.kdl 2>/dev/null || printf 'hotkey-overlay {\n    skip-at-startup\n}\n' >> ~/.config/niri/config.kdl
else
    START='exec $(command -v start-hyprland || command -v Hyprland) >/tmp/session.log 2>&1'
    systemctl --user add-wants hyprland-session.target dms || true
fi
grep -q 'tty)" = /dev/tty1' ~/.bash_profile 2>/dev/null || cat >> ~/.bash_profile <<P
[ -f ~/.bashrc ] && . ~/.bashrc
if [ "\$(tty)" = /dev/tty1 ] && [ -z "\${WAYLAND_DISPLAY:-}" ]; then $START; fi
P
mkdir -p ~/Pictures/Wallpapers
