# Подключается из обёрток oboi-*. helper_ready <бинарник>: 0, если собранный помощник здесь работает.
# Бинарник при первом запуске распаковывается в ~/.cache/oboi/helper-<хэш>. Два процесса, начавшие
# распаковку одновременно, падают (SIGBUS), поэтому первый запуск идёт под блокировкой. В метке
# helper-ok-<размер>-<время> записан каталог распаковки: пропал каталог, значит проверяем заново.
# Неудачу не запоминаем: включили nix-ld или поправили права, и следующий запуск снова попробует.
helper_ready() {
    c=${XDG_CACHE_HOME:-}; [ -n "$c" ] || c=$HOME/.cache; c=$c/oboi
    mkdir -p "$c" 2>/dev/null || return 1
    tag=$(stat -c %s-%Y "$1" 2>/dev/null) || return 1
    ok=$c/helper-ok-$tag
    [ -f "$ok" ] && [ -d "$(cat "$ok" 2>/dev/null)" ] && return 0
    (
        flock -w 120 9 || exit 1
        [ -f "$ok" ] && [ -d "$(cat "$ok" 2>/dev/null)" ] && exit 0
        timeout 120 "$1" index --help >/dev/null 2>&1 || exit 1
        dir=$(ls -dt "$c"/helper-*/ 2>/dev/null | head -n 1)
        [ -n "$dir" ] || exit 1
        rm -f "$c"/helper-ok-*
        echo "${dir%/}" > "$ok"
        # прежние распакованные версии (~180 МБ каждая) старше суток: ими уже никто не пользуется
        find "$c" -maxdepth 1 -type d -name 'helper-*' -mmin +1440 ! -path "${dir%/}" -exec rm -rf {} + 2>/dev/null
        exit 0
    ) 9>"$c/helper.lock"
}
