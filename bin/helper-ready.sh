# Подключается из обёрток oboi-*.
# helper_ready <бинарник>: 0, если собранный помощник здесь работает. Бинарник при первом запуске
# распаковывается в ~/.cache/oboi/helper-<хэш>; два процесса, начавшие распаковку одновременно,
# падают (SIGBUS), поэтому первый запуск идёт под блокировкой. Блокировка через mkdir: flock -w
# нет в BusyBox, а mkdir есть везде. В метке helper-ok-<размер>-<время> записан каталог, который
# назвал сам бинарник (oboi-helper where): пропал каталог, значит проверяем заново.
# Неудачу не запоминаем: включили nix-ld или поправили права, и следующий запуск снова попробует.
helper_ready() {
    c=${XDG_CACHE_HOME:-}; [ -n "$c" ] || c=$HOME/.cache; c=$c/oboi
    mkdir -p "$c" 2>/dev/null || return 1
    tag=$(stat -c %s-%Y "$1" 2>/dev/null) || return 1
    ok=$c/helper-ok-$tag
    if [ -f "$ok" ] && [ -d "$(cat "$ok" 2>/dev/null)" ]; then
        helper_prune "$c" "$(cat "$ok")"
        return 0
    fi
    lock=$c/helper.lock.d i=0
    until mkdir "$lock" 2>/dev/null; do
        # чужая блокировка старше двух минут осталась от упавшего процесса
        [ -n "$(find "$lock" -maxdepth 0 -mmin +2 2>/dev/null)" ] && rmdir "$lock" 2>/dev/null && continue
        i=$((i + 1)); [ $i -gt 600 ] && return 1
        sleep 0.2
    done
    r=1
    if [ -f "$ok" ] && [ -d "$(cat "$ok" 2>/dev/null)" ]; then
        r=0
    else
        dir=$("$1" where 2>/dev/null) && [ -d "$dir" ] && "$1" index --help >/dev/null 2>&1 && {
            rm -f "$c"/helper-ok-*; echo "$dir" > "$ok"; r=0; }
    fi
    rmdir "$lock" 2>/dev/null
    [ $r -eq 0 ] && helper_prune "$c" "$(cat "$ok")"
    return $r
}

# распакованные каталоги других версий (~180 МБ каждый), не тронутые больше суток
helper_prune() {
    find "$1" -maxdepth 1 -type d -name 'helper-*' -mmin +1440 ! -path "$2" -exec rm -rf {} + 2>/dev/null
    return 0
}

# helper_run <бинарник> <команда> <аргументы…>: запустить проверенный бинарник дочерним процессом.
# Не exec: если он всё же не запустится (выключили nix-ld после проверки), обёртка перейдёт на Python.
# Сигнал от Quickshell (отмена поиска) пересылается бинарнику, stdin передаётся явно (смысловой
# помощник читает запросы со stdin, а фоновой команде оболочка иначе подставит /dev/null).
helper_run() {
    trap 'kill -TERM "$hp" 2>/dev/null' TERM INT HUP
    "$@" <&0 &
    hp=$!
    wait "$hp"; rc=$?
    while kill -0 "$hp" 2>/dev/null; do wait "$hp"; rc=$?; done
    trap - TERM INT HUP
    return $rc
}
