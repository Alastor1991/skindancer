#!/bin/bash
# Ubuntu 26.04: DMS из PPA duxlabs (dux-repo, dms) по инструкции duxlabs.dev, niri.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q
sudo apt-get install -yq software-properties-common linux-generic
sudo add-apt-repository -y ppa:duxlabs/dux-repo
sudo add-apt-repository -y ppa:duxlabs/dms
sudo apt-get update -q
sudo apt-get install -yq dms niri xwayland-satellite foot grim git python3-pil fonts-noto-core mesa-utils time
