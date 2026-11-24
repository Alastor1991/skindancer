// Без плагинной системы DMS: qs -c oboi (папка конфигурации Quickshell ~/.config/quickshell/oboi).
// Всё устройство в Oboi.qml; плагином DMS их запускает OboiDaemon.qml.
import Quickshell

ShellRoot {
    Oboi { }
}
