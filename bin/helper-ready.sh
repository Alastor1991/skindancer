# Подключается из обёрток oboi-*. helper_ready <бинарник>: 0, если собранный помощник здесь работает.
# Бинарник при первом запуске распаковывается в ~/.cache/oboi/helper-<хэш>. Два процесса, начавшие
# распаковку одновременно, падают (SIGBUS), поэтому первый запуск идёт под блокировкой, а итог
# запоминается меткой по размеру и времени файла. Старые распакованные версии убираются.
helper_ready() {
    c=${XDG_CACHE_HOME:-$HOME/.cache}/oboi
    [ -n "${XDG_CACHE_HOME:-}" ] || c=$HOME/.cache/oboi
    mkdir -p "$c" 2>/dev/null || return 1
    tag=$(stat -c %s-%Y "$1" 2>/dev/null) || return 1
    [ -f "$c/helper-ok-$tag" ] && return 0
    [ -f "$c/helper-bad-$tag" ] && return 1
    (
        flock 9
        [ -f "$c/helper-ok-$tag" ] || [ -f "$c/helper-bad-$tag" ] && exit 0
        if "$1" index --help >/dev/null 2>&1; then
            rm -f "$c"/helper-ok-* "$c"/helper-bad-*
            touch "$c/helper-ok-$tag"
            # распакованные каталоги прежних версий (~180 МБ каждый): оставляем только самый свежий
            ls -dt "$c"/helper-*/ 2>/dev/null | tail -n +2 | while read -r old; do rm -rf "$old"; done
        else
            touch "$c/helper-bad-$tag"
        fi
    ) 9>"$c/helper.lock"
    [ -f "$c/helper-ok-$tag" ]
}
