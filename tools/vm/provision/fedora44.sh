#!/bin/bash
# Fedora 44: DMS из COPR duxlabs/dms и duxlabs/dux-repo по инструкции duxlabs.dev, niri.
# --disablerepo=fedora-cisco-openh264: codecs.fedoraproject.org (Cisco) из России отвечает 403.
set -euxo pipefail
sudo dnf install -yq dnf-plugins-core kernel-modules
sudo dnf copr enable -y duxlabs/dms
sudo dnf copr enable -y duxlabs/dux-repo
sudo dnf install -yq --disablerepo=fedora-cisco-openh264 dms niri xwayland-satellite foot grim git python3-pillow google-noto-serif-fonts mesa-demos time
