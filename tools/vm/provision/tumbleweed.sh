#!/bin/bash
# openSUSE Tumbleweed: DMS из OBS home:duxlabs-dev по инструкции duxlabs.dev, niri.
set -euxo pipefail
sudo zypper -n addrepo https://download.opensuse.org/repositories/home:duxlabs-dev:dux-repo/openSUSE_Tumbleweed/home:duxlabs-dev:dux-repo.repo || true
sudo zypper -n addrepo https://download.opensuse.org/repositories/home:/duxlabs-dev:/dms/openSUSE_Tumbleweed/home:duxlabs-dev:dms.repo || true
sudo zypper -n --gpg-auto-import-keys refresh
# codecs.opensuse.org (кодек Cisco openh264) отвечает из России 403, и zypper бросает всю установку;
# без этого репозитория встаёт пустышка libopenh264 из oss
for a in $(zypper -q lr | awk -F'|' 'tolower($0) ~ /openh264/ {gsub(/ /,"",$2); print $2}'); do sudo zypper -n mr -d "$a"; done
# libwayland-server0: niri в минимальном образе иначе падает с NoWaylandLib
# zypper может закончить «with error» на скриптах пакетов; годно, если нужное встало
sudo zypper -n install --force-resolution kernel-default libwayland-server0 dms niri xwayland-satellite foot grim git python313-Pillow Mesa-demo-x time || true
rpm -q dms niri kernel-default python313-Pillow
