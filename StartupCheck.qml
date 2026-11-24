// Проверка при включении плагина. Хватает одного из двух: собранного bin/oboi-helper
// (все библиотеки внутри) или python3 с Pillow для индекса и миниатюр.
// Смысловой поиск необязателен: без onnxruntime лента ищет по словам.
import QtQuick
import qs.Common

QtObject {
    function check(done) {
        Proc.runCommand("skindancer.depCheck", ["sh", "-c", '{ test -f "$1" && test -x "$1" && "$1" index --help >/dev/null 2>&1; } || python3 -c "import PIL"', "sh",
                                             decodeURIComponent(Qt.resolvedUrl("bin/oboi-helper").toString().replace(/^file:\/\//, ""))], (stdout, exitCode) => {
            if (exitCode === 0) {
                done(null);
                return;
            }
            done({
                title: I18n.trFor("skindancer", "Skindancer needs its helpers"),
                details: I18n.trFor("skindancer", "Put oboi-helper from the GitHub release into the plugin's bin folder, or install python-pillow (Arch: sudo pacman -S python-pillow). Then enable the plugin again.")
            });
        });
    }
}
