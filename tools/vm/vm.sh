#!/usr/bin/env bash
# Виртуалки для проверки Skindancer на разных дистрибутивах. Запускается на машине с KVM.
# Образы и диски лежат в $VMDIR (по умолчанию ~/skindancer-vm); образы скачать в $VMDIR/images.
#
#   tools/vm/vm.sh up <имя>       создать диск поверх облачного образа (если его нет) и запустить
#   tools/vm/vm.sh ssh <имя> [команда …]
#   tools/vm/vm.sh down <имя>     выключить
#   tools/vm/vm.sh reset <имя>    выключить и удалить диск, следующий up начнёт с чистого образа
#   tools/vm/vm.sh list
#
# Машины: debian13 ubuntu2604 fedora44 tumbleweed arch. KVM без libvirt и без root:
# /dev/kvm доступен всем, сеть пользовательская, ssh проброшен на 127.0.0.1:<порт>.
# Графика virtio-gpu с OpenGL через egl-headless (рендерит Radeon хозяина), окна нет;
# смотреть на экран гостя снимками изнутри (grim) или через VNC на 127.0.0.1:59<NN>.
# Вход: пользователь oboi, ключ ~/.ssh/id_ed25519 хозяина, пароль oboi (консоль, sudo без пароля).
set -euo pipefail
VMDIR=${VMDIR:-$HOME/skindancer-vm}
IMG=$VMDIR/images
KEY=${KEY:-$HOME/.ssh/id_ed25519}

declare -A IMAGE=(
    [debian13]=debian-13-genericcloud-amd64.qcow2
    [ubuntu2604]=resolute-server-cloudimg-amd64.img
    [fedora44]=Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2
    [tumbleweed]=openSUSE-Tumbleweed-Minimal-VM.x86_64-Cloud.qcow2
    [arch]=Arch-Linux-x86_64-cloudimg.qcow2
    [nixos]=nixos-26.05.qcow2          # собирается tools/vm/nixos/build.sh, ключ ssh уже внутри
)
declare -A NUM=([debian13]=1 [ubuntu2604]=2 [fedora44]=3 [tumbleweed]=4 [arch]=5 [nixos]=6)

die() { echo "vm.sh: $*" >&2; exit 1; }
# PID из файла годится, только если это наш qemu с этой машиной: после перезагрузки хозяина
# номер мог достаться чужому процессу, и его нельзя ни считать «запущенной машиной», ни убивать
ourpid() { local f=$VMDIR/$1/pid p; [[ -f $f ]] || return 1; p=$(cat "$f"); \
           tr '\0' ' ' 2>/dev/null < "/proc/$p/cmdline" | grep -q -- "-name oboi-$1 " && echo "$p"; }
need() { [[ -n ${IMAGE[$1]:-} ]] || die "нет машины «$1»; есть: ${!IMAGE[*]}"; }
port() { echo $((2200 + NUM[$1])); }

seed() {   # cloud-init: пользователь oboi с ключом, sudo без пароля, диск во весь размер
    local d=$VMDIR/$1/seed; mkdir -p "$d"
    [[ -f $KEY.pub ]] || die "нет $KEY.pub"
    cat > "$d/meta-data" <<EOF
instance-id: oboi-$1
local-hostname: $1
EOF
    cat > "$d/user-data" <<EOF
#cloud-config
users:
  - name: oboi
    groups: [wheel, sudo, video, render, input, audio]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    plain_text_passwd: oboi
    ssh_authorized_keys: ["$(cat "$KEY.pub")"]
growpart: {mode: auto, devices: ["/"]}
resize_rootfs: true
ssh_pwauth: false
EOF
    mkisofs -quiet -output "$VMDIR/$1/seed.iso" -volid cidata -joliet -rock "$d/user-data" "$d/meta-data"
}

up() {
    need "$1"; local n=$1 dir=$VMDIR/$1
    [[ -f $IMG/${IMAGE[$n]} ]] || die "образ ${IMAGE[$n]} ещё не скачан"
    ourpid "$n" >/dev/null && { echo "$n уже запущена"; return; }
    mkdir -p "$dir"
    if [[ ! -f $dir/disk.qcow2 ]]; then
        qemu-img create -q -f qcow2 -F qcow2 -b "$IMG/${IMAGE[$n]}" "$dir/disk.qcow2" 40G
        seed "$n"
    fi
    qemu-system-x86_64 -name "oboi-$n" -enable-kvm -machine q35 -cpu host -smp 4 -m 6144 \
        -drive file="$dir/disk.qcow2",if=virtio,discard=unmap \
        -drive file="$dir/seed.iso",media=cdrom,readonly=on \
        -netdev user,id=n0,hostfwd=tcp:127.0.0.1:"$(port "$n")"-:22 -device virtio-net-pci,netdev=n0 \
        -device virtio-vga-gl,xres=1920,yres=1080 -display egl-headless,rendernode=/dev/dri/renderD128 \
        -vnc 127.0.0.1:$((90 + NUM[$n])) \
        -device virtio-keyboard-pci -device virtio-tablet-pci \
        -audiodev none,id=snd0 -device intel-hda -device hda-duplex,audiodev=snd0 \
        -serial file:"$dir/serial.log" -daemonize -pidfile "$dir/pid"
    echo "$n запущена: ssh -p $(port "$n") oboi@127.0.0.1, VNC 127.0.0.1:59$((90 + NUM[$n]))"
    for _ in $(seq 1 90); do
        ssh_ "$n" true 2>/dev/null && { echo "ssh готов"; return; }
        sleep 2
    done
    die "$n: ssh не поднялся за 3 минуты, смотри $dir/serial.log"
}

ssh_() {
    local n=$1; shift
    ssh -q -i "$KEY" -p "$(port "$n")" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=5 -o BatchMode=yes oboi@127.0.0.1 "$@"
}

down() {
    need "$1"; local f=$VMDIR/$1/pid p
    p=$(ourpid "$1") || { rm -f "$f"; echo "$1 не запущена"; return; }
    ssh_ "$1" sudo poweroff 2>/dev/null || true
    for _ in $(seq 1 30); do ourpid "$1" >/dev/null || break; sleep 1; done
    ourpid "$1" >/dev/null && kill "$p" 2>/dev/null || true
    rm -f "$f"; echo "$1 выключена"
}

case ${1:-} in
    up) up "${2:?имя}" ;;
    ssh) need "${2:?имя}"; n=$2; shift 2; ssh_ "$n" "$@" ;;
    down) down "${2:?имя}" ;;
    reset) need "${2:?имя}"; down "$2"; rm -f "$VMDIR/$2/disk.qcow2" "$VMDIR/$2/seed.iso"; echo "$2: диск удалён" ;;
    list) for n in "${!IMAGE[@]}"; do
              s=выключена; ourpid "$n" >/dev/null && s=работает
              printf '%-11s %-10s ssh :%s  образ %s\n' "$n" "$s" "$(port "$n")" \
                  "$([[ -f $IMG/${IMAGE[$n]} ]] && echo есть || echo нет)"
          done ;;
    *) sed -n 2,16p "$0"; exit 1 ;;
esac
