#!/usr/bin/env bash
# Arch: DMS из официального extra (dux-shell), Hyprland. Обои: python-pillow.
set -euxo pipefail
sudo pacman -Syu --noconfirm --needed dux-shell hyprland xdg-desktop-portal-hyprland foot grim git python-pillow noto-fonts mesa-utils time
