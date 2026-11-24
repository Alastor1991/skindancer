#!/bin/bash
# Debian 13: DMS по инструкции duxlabs.dev (quickshell из trixie-backports, dms и niri из OBS duxlabs-dev),
# обычное ядро вместо облачного (в облачном нет virtio-gpu), автовход в niri на tty1.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q
sudo apt-get install -yq linux-image-amd64 curl gpg ca-certificates
echo 'deb http://deb.debian.org/debian trixie-backports main' | sudo tee /etc/apt/sources.list.d/backports.list
sudo install -d /etc/apt/keyrings
for r in dms dux-repo; do
    curl -fsSL "https://download.opensuse.org/repositories/home:/duxlabs-dev:/$r/Debian_13/Release.key" \
        | gpg --dearmor | sudo tee "/etc/apt/keyrings/home-duxlabs-dev-$r.gpg" >/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/home-duxlabs-dev-$r.gpg] https://download.opensuse.org/repositories/home:/duxlabs-dev:/$r/Debian_13/ /" \
        | sudo tee "/etc/apt/sources.list.d/duxlabs-$r.list"
done
sudo apt-get update -q
sudo apt-get install -yq -t trixie-backports quickshell
sudo apt-get install -yq dms niri xwayland-satellite foot grim git python3-pil fonts-noto-core mesa-utils
