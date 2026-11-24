#!/usr/bin/env bash
# С рабочей машины: полный круг проверки Skindancer на одной виртуалке машины с KVM.
#   VM_HOST=user@host [VM_REPO=путь/к/репо] [VMDIR=…] [WALLS=папка с обоями] tools/vm/run-distro.sh <машина>
# Поднимает машину, ставит DMS по provision/<машина>.sh и автовход (provision/session.sh),
# перезагружается, ставит плагин как в README, гоняет test-plugin.sh на Python,
# затем кладёт собранный oboi-helper и гоняет ещё раз, результаты кладёт в build/vm/<машина>/.
set -euo pipefail
R=$(cd "$(dirname "$0")/../.." && pwd)
# машина с KVM, где живут виртуалки (ssh), путь к репозиторию на ней и папка с тестовыми обоями здесь
M=${VM_HOST:?задай VM_HOST=пользователь@адрес машины с KVM}
RR=${VM_REPO:-skindancer}
WALLS=${WALLS:-$HOME/Pictures/Wallpapers}
VMENV="VMDIR=${VMDIR:-\$HOME/skindancer-vm}"
N=${1:?машина}
OUT=$R/build/vm/$N; mkdir -p "$OUT"
LOG=$OUT/run.log; : > "$LOG"
say() { echo "[$N] $*" | tee -a "$LOG"; }
vm() { ssh "$M" "cd ~/$RR && $VMENV tools/vm/vm.sh $*"; }
vmsh() { ssh "$M" "cd ~/$RR && $VMENV tools/vm/vm.sh ssh $N bash -s"; }
put() { ssh "$M" "cd ~/$RR && $VMENV tools/vm/vm.sh ssh $N 'cat > $2'" < "$1"; }
wait_up() { sleep 40; for _ in $(seq 1 40); do vm ssh "$N" true 2>/dev/null && return; sleep 5; done; say "не поднялась"; exit 1; }

# на мини ПК 12 ГБ: машина не должна остаться включённой, если прогон упал
trap 'vm down "$N" >> "$LOG" 2>&1 || true' EXIT
scp -q "$R/tools/vm/vm.sh" "$M:$RR/tools/vm/vm.sh"
say "запуск"; vm up "$N" >> "$LOG" 2>&1
if ! vm ssh "$N" test -f .provisioned 2>/dev/null; then
    say "ставлю DMS"
    vmsh < "$R/tools/vm/provision/$N.sh" >> "$LOG" 2>&1 || { say "установка DMS упала, хвост лога:"; tail -20 "$LOG"; exit 1; }
    vmsh < "$R/tools/vm/provision/session.sh" >> "$LOG" 2>&1
    vm ssh "$N" touch .provisioned
    vm ssh "$N" sudo reboot >> "$LOG" 2>&1 || true; wait_up
fi
say "сеанс: $(echo "systemctl --user is-active dms; ls /dev/dri" | vmsh 2>&1 | tr "\n" " ")"

git -C "$R" bundle create -q "$OUT/skindancer.bundle" HEAD
put "$OUT/skindancer.bundle" /tmp/skindancer.bundle
{ ls "$WALLS" | grep -iE '\.(jpe?g|png|webp)$' || true; } | head -16 > "$OUT/walls.txt" || true
tar -C "$WALLS" -cf - -T "$OUT/walls.txt" | ssh "$M" "cd ~/$RR && $VMENV tools/vm/vm.sh ssh $N 'mkdir -p ~/Pictures/Wallpapers && tar -C ~/Pictures/Wallpapers -xf -'"
put "$R/tools/vm/test-plugin.sh" test-plugin.sh; vm ssh "$N" chmod +x test-plugin.sh

vm ssh "$N" rm -f /tmp/oboi-helper
say "плагин по README"; vmsh < "$R/tools/vm/install-plugin.sh" >> "$LOG" 2>&1
RC=0
say "прогон на Python"; set +e; vm ssh "$N" ./test-plugin.sh python 2>&1 | tee -a "$LOG" | grep -E "^== (помощники|индекс|обои|ОБОИ|ЕСТЬ)|^индекс|ЦП"
r=${PIPESTATUS[0]}; set -e; [ "$r" -eq 0 ] || { RC=1; say "прогон на Python не прошёл"; }
if [[ -x $R/bin/oboi-helper ]]; then
    # второй прогон как у человека, скачавшего бинарник из релиза: он лежит в bin до включения плагина
    put "$R/bin/oboi-helper" /tmp/oboi-helper
    say "плагин с бинарником"; vmsh < "$R/tools/vm/install-plugin.sh" >> "$LOG" 2>&1
    say "прогон на бинарнике"; set +e; vm ssh "$N" ./test-plugin.sh binary 2>&1 | tee -a "$LOG" | grep -E "^== (помощники|ОБОИ|обои сменились|ЕСТЬ)|^индекс"
    r=${PIPESTATUS[0]}; set -e; [ "$r" -eq 0 ] || { RC=1; say "прогон на бинарнике не прошёл"; }
fi
ssh "$M" "cd ~/$RR && $VMENV tools/vm/vm.sh ssh $N 'tar -C ~/oboi-test -cf - .'" | tar -C "$OUT" -xf -
say "готово: $OUT"
exit $RC
