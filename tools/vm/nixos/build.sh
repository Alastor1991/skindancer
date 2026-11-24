#!/usr/bin/env bash
# Собирает qcow2 с NixOS в контейнере nixos/nix; результат tools/vm/nixos/out/nixos-26.05.qcow2.
# /nix контейнера живёт в томе skindancer-nix, повторная сборка не качает всё заново.
set -euo pipefail
cd "$(dirname "$0")"
[ -f key.pub ] || { echo "положи сюда key.pub (ssh-ключ машины, с которой заходишь в виртуалку)"; exit 1; }
mkdir -p out
ENGINE=$(command -v podman || command -v docker)
"$ENGINE" run --rm --device /dev/kvm -v skindancer-nix:/nix -v "$PWD:/work:z" -w /work docker.io/nixos/nix:latest sh -euc '
  nix --extra-experimental-features "nix-command flakes" build --print-build-logs \
      .#nixosConfigurations.vm.config.system.build.images.qemu -o /tmp/result
  cp -L /tmp/result/*.qcow2 out/nixos-26.05.qcow2; chmod u+w out/nixos-26.05.qcow2'
ls -lh out/
