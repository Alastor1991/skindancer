// Справка: как пользоваться лентой.
// Открывается из меню стола («Справка»), из ленты по F1 и через IPC: qs -c oboi ipc call oboi help
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: help
    required property var shell
    readonly property bool open: shell.helpScreen !== null
    visible: open || card.opacity > 0
    property var lastScreen: null       // пока справка гаснет, helpScreen уже null: без вспышки на первом мониторе
    Connections { target: help.shell; function onHelpScreenChanged() { if (help.shell.helpScreen) help.lastScreen = help.shell.helpScreen; } }
    screen: shell.helpScreen || lastScreen || Quickshell.screens[0]
    color: "transparent"
    WlrLayershell.namespace: "oboi:help"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    function close() { shell.helpScreen = null; }

    // Строки по-английски, перевод из translations/<язык>.json; команды и пути не переводятся
    readonly property var sections: [
        { title: "Wallpapers", rows: [
            ["← →, wheel", "browse; in the wall and wallhaven views the arrows move by cells, ↑ ↓ by rows"],
            ["Enter, click the selected one", "set as wallpaper; in the wallhaven tab, save the image to your wallpaper folder"],
            ["Ctrl+D, star", "add to favorites; the star next to the colors shows favorites only"],
            ["Color dots", "only wallpapers of this color; click again to clear the filter"],
            ["Search", "by titles and descriptions; queries in English also search by meaning: desert, rain"],
            ["Ctrl+1 2 3", "view: strip, wall, depth"],
            ["Ctrl+4", "wallhaven: search online, filters under the search field"],
            // третий элемент-строка: строка только для своего запуска ("own") или только в DMS ("dms")
            ["Gear", "settings: transition, view, bounce, captions, hints, language", "own"],
            ["Gear", "settings: transition, view, bounce, captions, hints", "dms"],
            ["F1, Esc", "this help; Esc closes it"]
        ] }
    ]

    readonly property var shown: sections

    Rectangle {
        anchors.fill: parent
        color: "#05080c"
        opacity: help.open ? 0.55 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        MouseArea { anchors.fill: parent; onClicked: help.close() }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(1180, help.width - 120)
        height: body.implicitHeight + 64
        radius: 28
        color: help.shell.panel
        border.color: Qt.rgba(0.91, 0.78, 0.60, 0.30); border.width: 1
        opacity: help.open ? 1 : 0
        scale: help.open ? 1 : 0.94
        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on scale { SpringAnimation { spring: 3.5; damping: 0.32 } }
        MouseArea { anchors.fill: parent }          // клик по карточке не закрывает справку

        Row {
            id: body
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 32 }
            spacing: 40
            Repeater {
                model: help.shown
                delegate: Column {
                    required property var modelData
                    width: (body.width - body.spacing * (help.shown.length - 1)) / help.shown.length
                    spacing: 10
                    Text { text: help.shell.tr(modelData.title); font.family: help.shell.serif; font.pixelSize: 26; font.italic: true; color: help.shell.gold }
                    Item { width: 1; height: 4 }
                    Repeater {
                        model: modelData.rows.filter(r => typeof r[2] !== "string" || r[2] === (help.shell.hosted ? "dms" : "own"))
                        delegate: Row {
                            required property var modelData
                            width: parent.width
                            spacing: 14
                            Text { width: 190; text: help.shell.tr(modelData[0]); wrapMode: Text.WordWrap
                                   font.family: help.shell.serif; font.pixelSize: 15; color: help.shell.ink }
                            Text { width: parent.width - 204; text: modelData[2] === true ? modelData[1] : help.shell.tr(modelData[1]); wrapMode: Text.WordWrap
                                   font.family: help.shell.serif; font.pixelSize: 15; color: help.shell.inkDim }
                        }
                    }
                }
            }
        }
    }
    Item {
        focus: help.open
        Keys.onPressed: e => { if (e.key === Qt.Key_Escape || e.key === Qt.Key_F1) { help.close(); e.accepted = true; } }
    }
}
