// Скошенная карточка со скруглёнными углами (параллелограмм).
// Служит маской для картинки и рамкой выбранной карточки.
import QtQuick
import QtQuick.Shapes

Shape {
    id: s
    property real skew: 0.16          // сдвиг верха относительно низа, в долях высоты
    property real radius: 18
    property color fill: "white"
    property color stroke: "transparent"
    property real strokeWidth: 0
    preferredRendererType: Shape.CurveRenderer
    antialiasing: true

    readonly property real off: height * skew / 2
    readonly property real rr: Math.max(0, Math.min(radius, height / 2, (width - 2 * off) / 2))
    // вершины: верх сдвинут вправо, низ влево
    readonly property point tl: Qt.point(off * 2, 0)
    readonly property point tr: Qt.point(width, 0)
    readonly property point br: Qt.point(width - off * 2, height)
    readonly property point bl: Qt.point(0, height)

    function towards(a, b, d) {
        const dx = b.x - a.x, dy = b.y - a.y, l = Math.sqrt(dx * dx + dy * dy) || 1;
        return Qt.point(a.x + dx / l * d, a.y + dy / l * d);
    }

    ShapePath {
        fillColor: s.fill
        strokeColor: s.stroke
        strokeWidth: s.strokeWidth
        joinStyle: ShapePath.RoundJoin
        startX: s.towards(s.tl, s.tr, s.rr).x; startY: s.towards(s.tl, s.tr, s.rr).y
        PathLine { x: s.towards(s.tr, s.tl, s.rr).x; y: s.towards(s.tr, s.tl, s.rr).y }
        PathQuad { controlX: s.tr.x; controlY: s.tr.y; x: s.towards(s.tr, s.br, s.rr).x; y: s.towards(s.tr, s.br, s.rr).y }
        PathLine { x: s.towards(s.br, s.tr, s.rr).x; y: s.towards(s.br, s.tr, s.rr).y }
        PathQuad { controlX: s.br.x; controlY: s.br.y; x: s.towards(s.br, s.bl, s.rr).x; y: s.towards(s.br, s.bl, s.rr).y }
        PathLine { x: s.towards(s.bl, s.br, s.rr).x; y: s.towards(s.bl, s.br, s.rr).y }
        PathQuad { controlX: s.bl.x; controlY: s.bl.y; x: s.towards(s.bl, s.tl, s.rr).x; y: s.towards(s.bl, s.tl, s.rr).y }
        PathLine { x: s.towards(s.tl, s.bl, s.rr).x; y: s.towards(s.tl, s.bl, s.rr).y }
        PathQuad { controlX: s.tl.x; controlY: s.tl.y; x: s.towards(s.tl, s.tr, s.rr).x; y: s.towards(s.tl, s.tr, s.rr).y }
    }
}
