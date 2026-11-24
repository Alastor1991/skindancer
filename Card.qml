// Карточка обоев для всех видов: картинка под маской скоса, рамка, звезда избранного,
// точка «стоит сейчас». Клики обрабатывает вид, кроме звезды на выбранной карточке.
import QtQuick
import QtQuick.Effects

Item {
    id: card
    required property var win          // окно выбора: палитра, избранное, текущие обои
    property var entry: null
    property bool isCur: false
    property bool load: true            // false: картинку не грузить (карточка далеко от выбранной)
    property real skew: 0.11
    property real radius: 18
    property bool dim: !isCur
    // программная отрисовка Qt (нет GPU) не умеет MultiEffect: тогда картинка без маски скоса
    readonly property bool soft: GraphicsInfo.api === GraphicsInfo.Software

    Item {
        id: pic
        anchors.fill: parent
        visible: card.soft
        clip: card.soft
        layer.enabled: !card.soft
        Image {
            anchors.fill: parent
            source: card.load && card.entry ? card.win.shell.fileUrl(card.entry.thumb) : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.height: 540
            smooth: true
        }
        Rectangle { anchors.fill: parent; color: "#05080c"; opacity: card.dim ? 0.38 : 0
                    Behavior on opacity { NumberAnimation { duration: 250 } } }
    }
    Slant { id: shape; anchors.fill: parent; skew: card.skew; radius: card.radius; visible: false; layer.enabled: true }
    MultiEffect {
        visible: !card.soft
        anchors.fill: parent
        source: pic
        maskEnabled: true
        maskSource: shape
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }
    Slant { anchors.fill: parent; skew: card.skew; radius: card.radius; fill: "transparent"
            stroke: card.isCur ? card.win.shell.gold : Qt.rgba(1, 1, 1, 0.10); strokeWidth: card.isCur ? 2 : 1 }
    Image {       // избранное: на выбранной карточке звезда кликабельна
        readonly property bool fav: card.entry !== null && card.win.shell.favs[card.entry.path] === true
        visible: (fav || card.isCur) && card.width > 60
        opacity: fav ? 1 : 0.55
        source: Qt.resolvedUrl(fav ? "icons/star-filled.svg" : "icons/star.svg")
        sourceSize: Qt.size(22, 22); width: 22; height: 22
        anchors { right: parent.right; top: parent.top; rightMargin: 16 + card.height * card.skew * 0.1; topMargin: 12 }
        z: 5
        MouseArea { anchors.fill: parent; anchors.margins: -6; enabled: card.isCur; onClicked: card.win.toggleFavorite() }
    }
    Rectangle {   // отметка текущих обоев
        visible: card.entry !== null && card.entry.path === card.win.shell.current
        width: 8; height: 8; radius: 4; color: card.win.shell.gold
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 10 }
    }
}
