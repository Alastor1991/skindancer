// Выпадающий список в духе Дали. Значение подчёркнуто линией, которая под стрелкой оплывает,
// стрелка сделана каплей. Список раскрывается упругим листом, с нижнего края которого стекают
// потёки, как с растёкшихся часов.
// Подпись, варианты [значение, надпись], value; если задан isOn, выбор множественный:
// список после щелчка не закрывается, а в поле перечислены отмеченные варианты.
// Клавиши в открытом списке: ↑ ↓, Enter или пробел выбирают, Esc и Tab закрывают.
import QtQuick
import QtQuick.Shapes

Item {
    id: c
    required property var shell
    property string label: ""
    property string ctx: ""             // контекст перевода вариантов: одно английское слово, разные переводы
    property int labelW: 0
    property int fieldW: 0              // 0: поле по ширине текста
    property var options: []
    property var value
    property var isOn: null
    signal picked(var v)

    property bool open: false
    readonly property bool multi: isOn !== null
    readonly property int rowH: 30
    readonly property int maxRows: 9

    function on(v) { return multi ? isOn(v) : v === value; }
    function optText(o) { return shell.trc(o[1], ctx || o[1]); }
    readonly property string shown: options.filter(o => on(o[0])).map(o => optText(o)).join(", ") || "–"

    implicitWidth: field.x + field.width
    implicitHeight: rowH

    onVisibleChanged: if (!visible) close()

    // список живёт поверх всего окна: иначе его обрезали бы и перекрывали соседи
    function host() { let p = c; while (p.parent) p = p.parent; return p; }

    function openList() {
        const h = host();
        layer.parent = h;
        let w = 0;
        for (const o of options) { tm.text = optText(o); w = Math.max(w, tm.advanceWidth); }
        sheet.width = Math.max(field.width + 24, Math.ceil(w) + 64);
        const pt = field.mapToItem(h, 0, field.height + 2);
        sheet.x = Math.max(8, Math.min(pt.x - 12, h.width - sheet.width - 8));
        sheet.y = Math.min(pt.y, h.height - sheet.height - 40);
        const i = options.findIndex(o => on(o[0]));
        list.currentIndex = i < 0 ? 0 : i;
        list.positionViewAtIndex(list.currentIndex, ListView.Contain);
        const win = c.Window.window;
        layer.prevFocus = win ? win.activeFocusItem : null;
        open = true;
        list.forceActiveFocus();
    }
    function close() {
        if (!open) return;
        open = false;
        if (layer.prevFocus) layer.prevFocus.forceActiveFocus();
        layer.prevFocus = null;
    }
    function choose(v) {
        picked(v);
        if (!multi) close();
    }

    TextMetrics { id: tm; font.family: c.shell.serif; font.pixelSize: 14 }

    readonly property bool hasLabel: label !== "" || labelW > 0
    Text {
        id: lab
        visible: c.hasLabel
        width: c.labelW > 0 ? c.labelW : undefined
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -2
        text: c.label ? c.shell.tr(c.label) : ""
        font.family: c.shell.serif; font.pixelSize: 14; color: c.shell.inkDim
    }

    Item {
        id: field
        x: c.hasLabel ? lab.width + 10 : 0
        width: Math.max(c.fieldW, val.implicitWidth + 30)
        height: c.rowH
        readonly property bool lit: c.open || hov.hovered
        HoverHandler { id: hov; cursorShape: Qt.PointingHandCursor }

        Text {
            id: val
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; verticalCenterOffset: -2 }
            width: Math.min(implicitWidth, parent.width - 22)
            elide: Text.ElideRight
            text: c.shown
            font.family: c.shell.serif; font.pixelSize: 14; font.italic: true
            color: field.lit ? c.shell.gold : c.shell.ink
            Behavior on color { ColorAnimation { duration: 140 } }
        }

        // подчёркивание: в одном месте линия провисает каплей, при наведении капля тяжелеет
        Shape {
            id: line
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true
            property real sag: c.open ? 5 : hov.hovered ? 3.2 : 1.4
            Behavior on sag { SpringAnimation { spring: 3; damping: 0.22 } }
            readonly property real y0: height - 4.5
            readonly property real dx: Math.round((width - 18) * 0.64)
            ShapePath {
                fillColor: "transparent"
                strokeColor: Qt.rgba(0.91, 0.78, 0.60, field.lit ? 0.75 : 0.38)
                strokeWidth: 1
                capStyle: ShapePath.RoundCap
                PathSvg {
                    path: {
                        const y = line.y0, d = line.dx, s = line.sag, e = line.width - 18;
                        return `M 0 ${y} L ${d - 6} ${y} C ${d - 2} ${y} ${d - 2.5} ${y + s} ${d} ${y + s}`
                             + ` C ${d + 2.5} ${y + s} ${d + 2} ${y} ${d + 6} ${y} L ${e} ${y}`;
                    }
                }
            }
        }

        // стрелка-капля: открытый список вытягивает её вниз
        Shape {
            id: drop
            width: 8; height: 11
            x: parent.width - 11
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -2
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true
            transform: Scale {
                origin.x: 4; origin.y: 0
                yScale: c.open ? 1.45 : hov.hovered ? 1.18 : 1
                xScale: c.open ? 0.86 : 1
                Behavior on yScale { SpringAnimation { spring: 4; damping: 0.2 } }
                Behavior on xScale { SpringAnimation { spring: 4; damping: 0.2 } }
            }
            ShapePath {
                fillColor: field.lit ? c.shell.gold : Qt.rgba(0.91, 0.78, 0.60, 0.7)
                strokeColor: "transparent"
                PathSvg { path: "M 4 0 C 4 0 0 5.5 0 7.5 A 4 4 0 0 0 8 7.5 C 8 5.5 4 0 4 0 Z" }
            }
        }

        MouseArea { anchors.fill: parent; onClicked: c.open ? c.close() : c.openList() }
    }

    // ── Раскрытый список ──
    Item {
        id: layer
        property var prevFocus: null
        z: 3000
        width: parent ? parent.width : 0
        height: parent ? parent.height : 0
        visible: c.open || sheet.opacity > 0.01

        // щелчок мимо списка только закрывает его и дальше не проходит
        MouseArea {
            anchors.fill: parent
            enabled: c.open
            onPressed: c.close()
            onWheel: w => w.accepted = true
        }

        Item {
            id: sheet
            readonly property int listH: Math.min(c.options.length, c.maxRows) * c.rowH
            height: listH + 16
            opacity: c.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: c.open ? 110 : 150 } }

            // лист раскрывается сверху вниз с упругим перехлёстом, потёки стекают следом
            property real sy: c.open ? 1 : 0.35
            Behavior on sy { SpringAnimation { spring: 3.2; damping: 0.26; epsilon: 0.002 } }
            transform: Scale { origin.x: sheet.width / 2; origin.y: 0; yScale: sheet.sy }
            property real melt: c.open ? 1 : 0
            Behavior on melt {
                SequentialAnimation {
                    PauseAnimation { duration: c.open ? 90 : 0 }
                    NumberAnimation { duration: c.open ? 900 : 120
                                      easing.type: c.open ? Easing.OutElastic : Easing.InQuad
                                      easing.amplitude: 1.2; easing.period: 0.42 }
                }
            }
            // пока список открыт, потёки медленно дышат
            property real breathe: 1
            SequentialAnimation on breathe {
                running: c.open
                loops: Animation.Infinite
                NumberAnimation { to: 1.16; duration: 2300; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.92; duration: 2300; easing.type: Easing.InOutSine }
            }

            Shape {
                id: bg
                width: sheet.width
                height: sheet.height + 46
                preferredRendererType: Shape.CurveRenderer
                antialiasing: true
                ShapePath {
                    fillColor: Qt.rgba(0.06, 0.085, 0.11, 0.96)
                    strokeColor: Qt.rgba(0.91, 0.78, 0.60, 0.34)
                    strokeWidth: 1
                    joinStyle: ShapePath.RoundJoin
                    PathSvg {
                        path: {
                            const w = sheet.width, h = sheet.height, r = 16, m = sheet.melt * sheet.breathe;
                            let p = `M ${r} 0 L ${w - r} 0 Q ${w} 0 ${w} ${r} L ${w} ${h - r} Q ${w} ${h} ${w - r} ${h}`;
                            // потёк: широкое основание, шейка и круглая капля на конце
                            // [доля ширины, длина, ширина основания]
                            for (const [f, len, dw] of [[0.8, 17, 16], [0.5, 32, 22], [0.19, 12, 14]]) {
                                const x = w * f, l = len * m, rb = Math.max(0.5, dw * 0.3 * Math.min(1, m)), nw = dw * 0.34;
                                const bY = h + l - rb, nY = h + Math.max(0, l - rb * 2.2);
                                p += ` L ${x + dw / 2} ${h} C ${x + dw * 0.2} ${h} ${x + nw / 2} ${h + l * 0.2} ${x + nw / 2} ${nY}`
                                   + ` C ${x + nw / 2} ${nY + rb * 0.5} ${x + rb} ${bY - rb * 0.6} ${x + rb} ${bY}`
                                   + ` A ${rb} ${rb} 0 0 1 ${x - rb} ${bY}`
                                   + ` C ${x - rb} ${bY - rb * 0.6} ${x - nw / 2} ${nY + rb * 0.5} ${x - nw / 2} ${nY}`
                                   + ` C ${x - nw / 2} ${h + l * 0.2} ${x - dw * 0.2} ${h} ${x - dw / 2} ${h}`;
                            }
                            return p + ` L ${r} ${h} Q 0 ${h} 0 ${h - r} L 0 ${r} Q 0 0 ${r} 0 Z`;
                        }
                    }
                }
            }

            ListView {
                id: list
                x: 0; y: 8
                width: sheet.width
                height: sheet.listH
                clip: true
                interactive: c.options.length > c.maxRows
                boundsBehavior: Flickable.StopAtBounds
                model: c.options
                keyNavigationEnabled: false
                Keys.onPressed: e => {
                    const k = e.key;
                    if (k === Qt.Key_Down || k === Qt.Key_Up) {
                        const n = c.options.length;
                        currentIndex = (currentIndex + (k === Qt.Key_Down ? 1 : -1) + n) % n;
                        positionViewAtIndex(currentIndex, ListView.Contain);
                    } else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) {
                        if (currentIndex >= 0) c.choose(c.options[currentIndex][0]);
                    } else if (k === Qt.Key_Escape || k === Qt.Key_Tab || k === Qt.Key_Backtab) {
                        c.close();
                    } else return;
                    e.accepted = true;
                }

                // внизу ещё есть варианты: край списка тает
                Rectangle {
                    parent: list
                    z: 2
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 1; rightMargin: 1 }
                    height: 34
                    visible: list.contentY + list.height < list.contentHeight - 2
                    gradient: Gradient {
                        GradientStop { position: 0; color: Qt.rgba(0.06, 0.085, 0.11, 0) }
                        GradientStop { position: 1; color: Qt.rgba(0.06, 0.085, 0.11, 0.96) }
                    }
                }

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: c.on(modelData[0])
                    readonly property bool hot: ListView.isCurrentItem
                    width: ListView.view.width
                    height: c.rowH

                    // строки проявляются по очереди сверху вниз
                    opacity: c.open ? 1 : 0
                    Behavior on opacity {
                        SequentialAnimation {
                            PauseAnimation { duration: c.open ? 30 + row.index * 22 : 0 }
                            NumberAnimation { duration: 160 }
                        }
                    }

                    Rectangle {
                        anchors { fill: parent; leftMargin: 6; rightMargin: 6; topMargin: 1; bottomMargin: 1 }
                        radius: 11
                        color: Qt.rgba(0.91, 0.78, 0.60, row.hot ? 0.13 : 0)
                        Behavior on color { ColorAnimation { duration: 90 } }
                    }

                    // метка выбора: капля; при множественном выборе пустое кольцо, пока вариант не отмечен
                    Rectangle {
                        visible: c.multi
                        x: 15; anchors.verticalCenter: parent.verticalCenter
                        width: 12; height: 12; radius: 6
                        color: "transparent"
                        border.color: Qt.rgba(0.91, 0.78, 0.60, row.sel ? 0 : 0.45); border.width: 1
                    }
                    Shape {
                        x: 17; width: 8; height: 11
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -1
                        preferredRendererType: Shape.CurveRenderer
                        antialiasing: true
                        scale: row.sel ? 1 : 0
                        Behavior on scale { SpringAnimation { spring: 5; damping: 0.25 } }
                        ShapePath {
                            fillColor: c.shell.gold
                            strokeColor: "transparent"
                            PathSvg { path: "M 4 0 C 4 0 0 5.5 0 7.5 A 4 4 0 0 0 8 7.5 C 8 5.5 4 0 4 0 Z" }
                        }
                    }

                    Text {
                        x: 36; anchors.verticalCenter: parent.verticalCenter
                        text: c.optText(row.modelData)
                        font.family: c.shell.serif; font.pixelSize: 14; font.italic: row.sel
                        color: row.sel ? c.shell.gold : row.hot ? c.shell.ink : Qt.rgba(0.95, 0.90, 0.84, 0.82)
                    }

                    HoverHandler { cursorShape: Qt.PointingHandCursor; onHoveredChanged: if (hovered) list.currentIndex = row.index }
                    MouseArea { anchors.fill: parent; onClicked: c.choose(row.modelData[0]) }
                }
            }
        }
    }
}
