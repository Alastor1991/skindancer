// Лента выбора обоев: скошенные карточки, выбранная упруго раздвигается.
// Поиск по имени, стилю, описанию, ключевым словам и тегам.
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: win
    required property var shell
    readonly property var pickerWin: win   // для Card: внутри неё имя win занято её собственным свойством

    readonly property bool open: shell.pickerScreen !== null
    property bool busy: false           // идёт переход: окно и экран держим до конца
    visible: open || busy || backdrop.opacity > 0
    // пока лента гаснет после закрытия, pickerScreen уже null: остаёмся на прежнем экране, без вспышки на первом
    property var lastScreen: null
    Connections { target: win.shell; function onPickerScreenChanged() { if (win.shell.pickerScreen) win.lastScreen = win.shell.pickerScreen; } }
    screen: shell.pickerScreen || lastScreen || Quickshell.screens[0]
    color: "transparent"
    WlrLayershell.namespace: "oboi:picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open && !busy && shell.helpScreen === null ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    // Наклон карточек: доля высоты, на которую сдвинут верх относительно низа
    readonly property real skew: 0.11
    // на вертикальном экране карточка 16:9 по высоте вылезла бы за края: тогда считаем от ширины
    readonly property real cardH: Math.round(Math.min(height * 0.40, width * 0.62 * 9 / 16))
    readonly property real cardW: Math.round(cardH * 16 / 9)
    readonly property real sliverW: Math.round(cardH * 0.26)

    property string view: "slices"      // slices (лента), wall (стена), depth (глубина)
    readonly property var views: [["slices", "Strip"], ["wall", "Wall"], ["depth", "Depth"]]
    function setView(v) { if (["slices", "wall", "depth"].indexOf(v) !== -1) view = v; }
    property string source: "local"     // local (мои обои) или wallhaven
    onSourceChanged: {
        // ушли со вкладки wallhaven: отложенный и идущий поиск гасим, их ответ уже никому не нужен
        if (source !== "wallhaven") whCancel();
        search.text = ""; if (source === "wallhaven") whFetch(true);
    }
    // ── wallhaven: поиск страницами, явное сохранение ──
    property var whItems: []
    property int whIndex: 0
    property int whPage: 1
    property int whLast: 1
    property int whGen: 0               // номер запроса: ответы на устаревший запрос отбрасываются
    property string whStatus: ""
    property int whTotal: 0
    property var whSaved: ({})
    readonly property var whChosen: whIndex >= 0 && whIndex < whItems.length ? whItems[whIndex] : null
    function whFetch(fresh) {
        if (source !== "wallhaven") return;
        // whLast сбрасываем раньше индекса: смена индекса на пустом списке иначе запросила бы страницу 2
        if (fresh) { whLast = 1; whPage = 1; whItems = []; whIndex = 0; whTotal = 0; }
        whGen += 1;
        const f = shell.wh;
        whPending = { gen: whGen, cmd: [shell.fetcher, "--search=" + query, "--page", String(whPage),
                                        "--atleast", f.atleast, "--ratios", f.ratios, "--categories", f.categories,
                                        "--purity", f.purity, "--sorting", f.sorting] };
        whStatus = shell.tr("Searching…");
        if (whProc.running) whProc.running = false;   // старый запрос прерываем, новый стартует в onExited
        else whStart();
    }
    property var whPending: null
    function whStart() {
        if (!whPending) return;
        whProc.gen = whPending.gen; whProc.command = whPending.cmd; whPending = null;
        whProc.running = true;
    }
    // лента закрыта или ушли с вкладки: поиск больше никому не нужен, процесс и таймер гасим
    function whCancel() {
        whDelay.stop(); whPending = null; whGen += 1;
        if (whProc.running) whProc.running = false;
    }
    function whMore() { if (!whProc.running && whPage < whLast) { whPage += 1; whFetch(false); } }
    function whFailed(msg) { win.whStatus = msg; if (win.whItems.length) win.whPage = Math.max(1, win.whPage - 1); }
    function whSave() {
        const it = whChosen;
        if (!it || whSaved[it.id] || saveProc.running) return;
        whStatus = shell.tr("Saving %1…", it.id);
        saveProc.wid = it.id;
        saveProc.command = [shell.fetcher, "--to", shell.saveDir, "--id", it.id, "--style", "wallhaven",
                            "--purity", shell.wh.purity, "--atleast", shell.wh.atleast];
        saveProc.running = true;
    }
    Process {
        id: whProc
        property int gen: 0
        environment: win.shell.fetchEnv
        // помощник упал или не запустился (не сам прерванный запрос): не висим на «Ищу…»
        property bool exitSeen: false
        onRunningChanged: {
            if (running) { exitSeen = false; return; }
            // процесс не запустился вовсе (нет файла, нет прав): exited тогда не приходит
            Qt.callLater(() => {
                if (!whProc.exitSeen && whProc.gen === win.whGen && !win.whPending) win.whFailed(win.shell.tr("wallhaven did not respond"));
                if (!whProc.exitSeen) win.whStart();
            });
        }
        onExited: code => {
            exitSeen = true;
            if (code !== 0 && whProc.gen === win.whGen && !win.whPending)
                win.whFailed(win.shell.tr("wallhaven did not respond"));
            win.whStart();
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (whProc.gen !== win.whGen || win.whPending) return;   // ответ на устаревший запрос
                if (!this.text.trim()) return;                           // процесс прервали
                let r;
                // при ошибке номер страницы откатываем, чтобы следующая прокрутка спросила её снова
                try { r = JSON.parse(this.text); } catch (e) { win.whFailed(win.shell.tr("wallhaven did not respond")); return; }
                if (r.error) { win.whFailed(win.shell.tr("Error: %1", r.error)); return; }
                win.whItems = win.whItems.concat(r.results);
                win.whLast = r.last_page || 1;
                win.whTotal = r.total || win.whItems.length;
                win.whStatus = win.whItems.length ? "" : win.shell.tr("Nothing found");
            }
        }
    }
    Process {
        id: saveProc
        property string wid: ""
        environment: win.shell.fetchEnv
        stdout: StdioCollector {
            onStreamFinished: {
                let r = {};
                try { r = JSON.parse(this.text); } catch (e) {}
                if (r.saved) {
                    const m = Object.assign({}, win.whSaved); m[saveProc.wid] = true; win.whSaved = m;
                    // в выбранную папку писать нельзя, помощник сохранил в <Картинки>/Wallpapers: обходим и её
                    win.shell.addExtraDir(String(r.saved).replace(/\/[^\/]*$/, ""));
                    win.whStatus = win.shell.tr("Saved to wallpapers"); win.shell.reindexNow();
                } else win.whStatus = win.shell.tr("Not saved: %1", r.error || win.shell.tr("no response"));
            }
        }
    }
    Timer { id: whDelay; interval: 600; onTriggered: win.whFetch(true) }

    property string query: ""
    property int hueFilter: -2          // -2 без фильтра, -1 серые, 0..11 оттенок
    property bool favOnly: false
    property var shown: merge(filter(shell.items, query), query).filter(e =>
        (hueFilter === -2 || e.hue === hueFilter) && (!favOnly || shell.favs[e.path] === true))
    // Слова находят сразу; когда приходит ответ смыслового поиска на этот же запрос,
    // к ним добавляются похожие по смыслу, и всё сортируется по близости
    function merge(byWords, q) {
        if (!shell.semEnabled || !q.trim() || shell.semQuery !== q) return byWords;
        const sc = shell.semScores, seen = {};
        byWords.forEach(e => seen[e.path] = true);
        const extra = shell.items.filter(e => !seen[e.path] && sc[e.path] !== undefined);
        const score = e => (sc[e.path] !== undefined ? sc[e.path] : 0) + (seen[e.path] ? 1 : 0);
        return byWords.concat(extra).sort((a, b) => score(b) - score(a));
    }
    Timer { id: semDelay; interval: 350; onTriggered: win.shell.semAsk(win.query) }
    property string keepPath: ""        // какую картинку держать выбранной, когда список перестраивается
    property string lastPath: ""        // последняя выбранная картинка: фоновый индекс не должен сбивать выбор
    property string preSearchPath: ""   // что было выбрано до поиска: после очистки поиска встаём туда
    onChosenChanged: if (chosen && !openPath) lastPath = chosen.path
    onShownChanged: {
        // при первом открытии индекс ещё строится: текущие обои появляются в списке позже
        if (openPath) { Qt.callLater(restoreOpen); return; }
        const want = keepPath || (query ? "" : lastPath);
        const i = want ? shown.findIndex(e => e.path === want) : -1;
        if (i >= 0) keepPath = "";          // просьба вернуть выбор исполняется один раз
        // ListView сбрасывает выбор, когда получает новую модель, поэтому возвращаем его на следующем такте
        if (i >= 0) Qt.callLater(() => jumpTo(i, 5));
    }
    property var chosen: list.currentIndex >= 0 && list.currentIndex < shown.length ? shown[list.currentIndex] : null

    // Поиск по началу слова с отбрасыванием окончания: «пустыня» найдёт «пустыне», «дали» не найдёт «вдали»
    readonly property var splitter: /[\s,.;:!?()«»"'\/_–-]+/
    function stem(w) {
        return w.length > 4 && "аеёиоуыэюяйь".indexOf(w[w.length - 1]) !== -1 ? w.slice(0, -1) : w;
    }
    function filter(all, q) {
        const words = q.toLowerCase().split(splitter).filter(w => w.length > 0).map(stem);
        if (words.length === 0) return all;
        return all.filter(e => {
            const toks = e._toks || (e._toks = e.search.split(splitter));
            return words.every(w => toks.some(t => t.startsWith(w)));
        });
    }

    function close() { if (!busy) shell.pickerScreen = null; }
    function toggleFavorite() {
        if (!chosen) return;
        userAct(); keepPath = chosen.path;
        shell.toggleFavorite(chosen.path);
    }
    function stepBy(d) {
        if (source === "wallhaven") whIndex = Math.max(0, Math.min(whItems.length - 1, whIndex + d));
        else list.step(d);
    }
    function setQuery(q) { search.text = q; }

    // Сетка как клетки: вправо и влево в пределах ряда, вверх и вниз на ряд; у края стоим на месте.
    // Внизу неполного ряда «вниз» встаёт на последнюю карточку, если ниже есть ряд.
    function gridMove(idx, count, cols, dx, dy) {
        if (count === 0) return idx;
        const row = Math.floor(idx / cols), col = idx % cols;
        if (dx !== 0) {
            const c = col + dx;
            return c < 0 || c >= cols || idx + dx >= count ? idx : idx + dx;
        }
        const n = idx + dy * cols;
        if (n < 0) return idx;
        if (n >= count) return Math.floor((count - 1) / cols) > row ? count - 1 : idx;
        return n;
    }
    function moveCell(dx, dy) {
        if (source === "wallhaven") whIndex = gridMove(whIndex, whItems.length, 5, dx, dy);
        else { userAct(); list.currentIndex = gridMove(list.currentIndex, list.count, grid.cols, dx, dy); }
    }
    readonly property bool gridMode: source === "wallhaven" || view === "wall"
    property bool settingsOpen: false
    property real gridWheelAcc: 0
    function gridWheel(w) {
        gridWheelAcc += w.angleDelta.y;
        while (gridWheelAcc <= -120) { moveCell(0, 1); gridWheelAcc += 120; }
        while (gridWheelAcc >= 120) { moveCell(0, -1); gridWheelAcc -= 120; }
    }

    // Скрытая лента теряет прокрутку, а StrictlyEnforceRange при показе выбирает карточку под центром,
    // то есть первую. Поэтому выбор текущих обоев повторяем, пока окно раскладывается,
    // и бросаем, как только пользователь сам листнул.
    property string openPath: ""
    property bool userMoved: false      // пользователь сам листал или искал после открытия
    function userAct() { openPath = ""; userMoved = true; keepPath = ""; }   // пользователь сам выбрал: восстанавливать больше нечего
    property bool jumping: false
    // Встать на карточку сразу, без проезда: пока лента ехала бы, карточки меняют ширину, и строгий
    // режим выбора останавливал её на соседней. ListView после новой модели может не принять номер
    // с первого раза, поэтому несколько попыток на следующих тактах.
    function jumpTo(i, tries) {
        jumping = true;
        if (list.currentIndex !== i) list.currentIndex = i;
        list.positionViewAtIndex(i, ListView.Center);
        Qt.callLater(() => {
            if (list.currentIndex !== i && tries > 0) jumpTo(i, tries - 1);
            else win.jumping = false;
        });
    }
    function restoreOpen() {
        if (!openPath) return;
        const j = shown.findIndex(e => e.path === openPath), i = Math.max(0, j);
        // пока лента проезжала бы к карточке, карточки меняют ширину, и строгий режим выбора
        // останавливал её на соседней (так было при первом открытии, когда индекс приходит позже)
        jumping = true; Qt.callLater(() => win.jumping = false);
        if (list.currentIndex !== i) list.currentIndex = i;
        list.positionViewAtIndex(i, ListView.Center);
        // ListView сразу после новой модели может не принять номер: тогда пробуем на следующем такте
        if (j >= 0 && list.currentIndex !== i) { Qt.callLater(restoreOpen); return; }
        // нашли и окно уже разложено: дальше выбор ведёт пользователь
        if (j >= 0 && !openGuard.running) { lastPath = openPath; openPath = ""; }
    }
    Timer { id: openGuard; interval: 900; onTriggered: win.restoreOpen() }
    // текущих обоев в списке так и нет (вертикальные, вне папки): перестаём ждать через 10 с после того,
    // как индекс собран (первый обход большой библиотеки идёт дольше 10 с)
    Timer { id: openWait; interval: 10000; onTriggered: if (win.shell.indexing) restart(); else win.openPath = "" }
    // текущие обои уточняются ответом `dms ipc wallpaper get` уже после открытия: пока пользователь
    // не листал, встаём на них, а не на путь, запомненный до открытия
    Connections {
        target: win.shell
        // и в самостоятельном запуске, где current сначала пустой: пока пользователь сам не выбрал карточку
        // индекс пришёл позже (первый обход большой библиотеки): ждём текущие обои ещё 10 с от этого момента
        function onItemsChanged() { if (win.open && win.openPath) openWait.restart(); }
        function onCurrentChanged() { if (win.open && !win.userMoved && win.shell.current) { win.openPath = win.shell.current; openWait.restart(); win.restoreOpen(); } }
    }

    onOpenChanged: {
        if (open) {
            source = "local"; query = ""; search.text = ""; morph.reset(); fx.reset(); settingsOpen = false;
            if (shell.startView !== "last") setView(shell.startView);
            openPath = shell.current; userMoved = false; lastPath = ""; preSearchPath = "";
            openGuard.restart(); openWait.restart();     // до restoreOpen: пока страж идёт, выбор не считается законченным
            restoreOpen();
            Qt.callLater(restoreOpen);
            search.forceActiveFocus();
        } else {
            whCancel();
        }
    }

    // Виды перехода: «grow» (карточка раздувается) и шейдеры. Выбор из config.json, иначе случайный.
    readonly property var kinds: ["grow", "iris", "dissolve", "melt", "ink"]
    property string forcedKind: ""      // для проверок через IPC
    function pickKind() {
        const pref = forcedKind || shell.transitionPref;
        if (kinds.indexOf(pref) !== -1) return pref;
        return kinds[Math.floor(Math.random() * kinds.length)];
    }

    property string applyScreen: ""     // монитор, выбранный в начале перехода: переход идёт секунду-другую
    function setWp(path) { shell.setWallpaper(path, applyScreen); }
    function apply() {
        if (source === "wallhaven") { whSave(); return; }
        if (!chosen || busy) return;
        busy = true;
        applyScreen = shell.targetName;
        const target = chosen.path, from = shell.current;
        let kind = pickKind();
        // без своего перехода (или без GPU: программная отрисовка шейдеры не тянет) DMS сменит обои сам
        if ((forcedKind || shell.transitionPref) === "none" || stage.soft) {
            setWp(target); busy = false; shell.pickerScreen = null; return;
        }
        // старые обои не картинка (цвет DMS, пусто) или не загрузились: шейдеру не из чего переходить
        if (kind !== "grow" && (!from || from === target || !from.startsWith("/") || fromImg.status === Image.Error)) kind = "grow";
        if (kind === "grow") {
            const it = list.currentItem;
            const p = it.mapToItem(win.contentItem, 0, 0);
            morph.start(target, p.x, p.y, it.width, it.height);
        } else {
            fx.start(kind, from, target);
        }
    }

    // Передача DMS: держим оверлей, пока `wallpaper get` не вернёт новый путь, но не дольше 4 с
    function handoff(target, alreadySet) {
        if (!alreadySet) setWp(target);
        hand.target = target; hand.since = Date.now(); hand.minUntil = Date.now() + (alreadySet ? 250 : 1050);
        poll.start();
    }
    function finish() {
        poll.stop();
        hideOverlay.restart();
    }
    QtObject { id: hand; property string target; property real since; property real minUntil; property bool confirmed }
    Process {
        id: getProc
        command: ["sh", "-c", 'r=$(dms ipc call wallpaper get); case "$r" in ERROR*) dms ipc call wallpaper getFor "$1";; *) echo "$r";; esac',
                  "sh", win.applyScreen]
        stdout: StdioCollector {
            onStreamFinished: if (this.text.trim() === hand.target) { hand.confirmed = true; win.shell.current = hand.target; }
        }
    }
    Timer {
        id: poll
        interval: 150; repeat: true
        onRunningChanged: if (running) hand.confirmed = false
        onTriggered: {
            const now = Date.now();
            // в плагине обои ставятся внутри DMS сразу, спрашивать `dms ipc` не нужно
            if (win.shell.hosted) { hand.confirmed = true; win.shell.current = hand.target; }
            if ((hand.confirmed && now >= hand.minUntil) || now - hand.since > 4000) win.finish();
            else if (!win.shell.hosted && !getProc.running) getProc.running = true;
        }
    }
    SequentialAnimation {
        id: hideOverlay
        ParallelAnimation {
            NumberAnimation { target: morph; property: "opacity"; to: 0; duration: 380; easing.type: Easing.InCubic }
            NumberAnimation { target: fx; property: "opacity"; to: 0; duration: 380; easing.type: Easing.InCubic }
        }
        ScriptAction { script: { win.busy = false; win.shell.pickerScreen = null; morph.reset(); fx.reset(); } }
    }
    // Затемнение позади ленты
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#05080c"
        opacity: win.open && !win.busy ? 0.62 : 0
        Behavior on opacity { NumberAnimation { id: fade; duration: 260; easing.type: Easing.OutCubic } }
        MouseArea { anchors.fill: parent; onClicked: win.close(); onWheel: w => win.gridMode ? win.gridWheel(w) : list.wheel(w) }
    }

    Item {
        id: stage
        // программная отрисовка Qt: прикреплённое GraphicsInfo читается только у элемента сцены, не у окна
        readonly property bool soft: GraphicsInfo.api === GraphicsInfo.Software
        anchors.fill: parent
        opacity: win.open && !win.busy ? 1 : 0
        scale: win.open ? 1 : 0.96
        Behavior on opacity { NumberAnimation { duration: 220 } }
        Behavior on scale { SpringAnimation { spring: 3; damping: 0.35 } }

        // Поиск
        Rectangle {
            id: searchBox
            // поле по центру, но не заезжает на переключатель видов справа (экраны 1366 и уже)
            width: Math.max(280, Math.min(620, win.width * 0.5, (viewBar.x - 28 - win.width / 2) * 2))
            height: 52
            radius: 26
            anchors { horizontalCenter: parent.horizontalCenter; bottom: list.top; bottomMargin: 46 }
            color: win.shell.panel
            border.color: Qt.rgba(0.91, 0.78, 0.60, search.activeFocus ? 0.55 : 0.25)
            border.width: 1
            Image { id: glass; source: Qt.resolvedUrl("icons/search.svg"); sourceSize: Qt.size(22, 22); width: 22; height: 22
                   anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter } }
            TextInput {
                id: search
                anchors { left: glass.right; leftMargin: 12; right: counter.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
                font.family: win.shell.serif; font.pixelSize: 18; color: win.shell.ink
                selectionColor: Qt.rgba(0.91, 0.78, 0.60, 0.35)
                clip: true
                onTextChanged: {
                    // запоминаем карточку до смены запроса: потом выбор уже уедет на первый результат
                    if (win.source === "local") {
                        if (text && !win.query && !win.preSearchPath) win.preSearchPath = win.chosen ? win.chosen.path : "";
                        if (!text && win.preSearchPath) { win.keepPath = win.preSearchPath; win.preSearchPath = ""; win.query = ""; win.userAct(); return; }
                    }
                    win.keepPath = ""; win.query = text;
                    if (win.source === "wallhaven") { whDelay.restart(); return; }
                    win.userAct(); if (text) list.currentIndex = 0; if (text.trim()) semDelay.restart();
                }
                Keys.onEscapePressed: win.settingsOpen ? (win.settingsOpen = false) : text.length ? (text = "") : win.close()
                Keys.onReturnPressed: win.source === "wallhaven" ? win.whSave() : win.apply()
                Keys.onEnterPressed: win.source === "wallhaven" ? win.whSave() : win.apply()
                // Стрелки листают, пока в поле нечего двигать: пустое поле или курсор на краю текста.
                // Tab и Shift+Tab листают всегда, Page Up/Down прыгают на 5, Home/End при пустом поле к краям ленты.
                Keys.onPressed: e => {
                    const empty = text.length === 0;
                    const k = e.key;
                    if ((e.modifiers & Qt.ControlModifier) && k === Qt.Key_4) {
                        if (win.shell.whEnabled) win.source = win.source === "wallhaven" ? "local" : "wallhaven";
                        e.accepted = true; return;
                    }
                    if (k === Qt.Key_F1) { win.shell.helpScreen = win.screen; e.accepted = true; return; }
                    // в сетках (стена, wallhaven) стрелки всегда ходят по клеткам, курсор в поле не двигают
                    if (win.gridMode && !(e.modifiers & Qt.ControlModifier)) {
                        const m = k === Qt.Key_Right ? [1, 0] : k === Qt.Key_Left ? [-1, 0]
                                : k === Qt.Key_Down ? [0, 1] : k === Qt.Key_Up ? [0, -1] : null;
                        if (m) { win.moveCell(m[0], m[1]); e.accepted = true; return; }
                    }
                    // Ctrl+1 2 3 и с вкладки wallhaven возвращают к своим обоям в выбранном виде
                    if ((e.modifiers & Qt.ControlModifier) && k >= Qt.Key_1 && k <= Qt.Key_3) {
                        win.source = "local"; win.view = win.views[k - Qt.Key_1][0]; e.accepted = true; return;
                    }
                    if (win.source === "wallhaven") {
                        const d = k === Qt.Key_Tab ? 1 : k === Qt.Key_Backtab ? -1 : k === Qt.Key_PageDown ? 15 : k === Qt.Key_PageUp ? -15 : 0;
                        if (d !== 0) { win.whIndex = Math.max(0, Math.min(win.whItems.length - 1, win.whIndex + d)); e.accepted = true; }
                        return;
                    }
                    if (k === Qt.Key_Tab || (k === Qt.Key_Right && (empty || cursorPosition === text.length))) list.step(1);
                    else if (k === Qt.Key_Backtab || (k === Qt.Key_Left && (empty || cursorPosition === 0))) list.step(-1);
                    else if (k === Qt.Key_PageDown) list.step(5);
                    else if (k === Qt.Key_PageUp) list.step(-5);
                    else if (k === Qt.Key_End && empty) list.step(list.count);
                    else if (k === Qt.Key_Home && empty) list.step(-list.count);
                    else if (k === Qt.Key_D && (e.modifiers & Qt.ControlModifier)) win.toggleFavorite();
                    else return;
                    e.accepted = true;
                }
                Text {
                    visible: !search.text.length
                    text: win.shell.tr("Search: sunset, anime, desert, neon…")
                    font: search.font; color: win.shell.inkDim; opacity: 0.7
                }
            }
            Text { id: counter; text: win.source === "wallhaven" ? (win.whItems.length ? (win.whIndex + 1) + " / " + win.whItems.length : "")
                                 : win.shown.length ? (list.currentIndex + 1) + " / " + win.shown.length
                                 : win.shell.indexing && win.shell.items.length === 0 ? win.shell.trc("loading…", "search counter")
                                 : win.shell.trc("nothing", "search counter")
                   font.family: win.shell.serif; font.pixelSize: 13; color: win.shell.inkDim
                   anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter } }
        }

        Row {
            id: swatches
            visible: win.source === "local"
            anchors { horizontalCenter: parent.horizontalCenter; top: searchBox.bottom; topMargin: 14 }
            spacing: 10
            Repeater {
                model: [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                delegate: Rectangle {
                    required property int modelData
                    readonly property bool on: win.hueFilter === modelData
                    width: 16; height: 16; radius: 8
                    color: modelData < 0 ? "#8a8580" : Qt.hsla((modelData + 0.5) / 12, 0.62, 0.55, 1)
                    border.color: on ? win.shell.gold : Qt.rgba(1, 1, 1, 0.18); border.width: on ? 2 : 1
                    scale: on ? 1.25 : 1
                    Behavior on scale { SpringAnimation { spring: 4; damping: 0.3 } }
                    MouseArea { anchors.fill: parent; anchors.margins: -4
                                onClicked: { win.userAct(); win.keepPath = win.chosen ? win.chosen.path : ""; win.hueFilter = parent.on ? -2 : parent.modelData; } }
                }
            }
            Item { width: 8; height: 1 }
            Image {
                source: Qt.resolvedUrl(win.favOnly ? "icons/star-filled.svg" : "icons/star.svg")
                sourceSize: Qt.size(18, 18); width: 18; height: 18; anchors.verticalCenter: parent.verticalCenter
                MouseArea { anchors.fill: parent; anchors.margins: -4
                            onClicked: { win.userAct(); win.keepPath = win.chosen ? win.chosen.path : ""; win.favOnly = !win.favOnly; } }
            }
        }

        // ── Фильтры wallhaven: меняются на лету, запрос уходит заново ──
        Column {
            id: whFilters
            visible: win.source === "wallhaven"
            anchors { horizontalCenter: parent.horizontalCenter; top: searchBox.bottom; topMargin: 14 }
            spacing: 8
            function setF(k, v) { win.shell.setWh(k, v); win.whFetch(true); }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30
                Choice { shell: win.shell; label: "Min resolution"; ctx: "resolution"; value: win.shell.wh.atleast
                        options: [["3840x2160", "4K"], ["2560x1440", "1440p"], ["1920x1080", "1080p"], ["", "Any"]]
                        onPicked: v => whFilters.setF("atleast", v) }
                Choice { shell: win.shell; label: "Aspect ratio"; ctx: "ratio"; value: win.shell.wh.ratios
                        options: [["16x9,16x10", "16:9 and 16:10"], ["21x9,32x9", "Ultrawide"], ["", "Any"]]
                        onPicked: v => whFilters.setF("ratios", v) }
                Choice { shell: win.shell; label: "Sort"; ctx: "sort"; value: win.shell.wh.sorting
                        options: [["", "Relevance"], ["toplist", "Top"], ["date_added", "Newest"], ["favorites", "Most favorited"], ["random", "Random"]]
                        onPicked: v => whFilters.setF("sorting", v) }
                Choice { shell: win.shell; label: "Categories"
                        options: [[0, "General"], [1, "Anime"], [2, "People"]]
                        isOn: v => win.shell.wh.categories[v] === "1"
                        onPicked: v => {
                            const c = win.shell.wh.categories.split("");
                            c[v] = c[v] === "1" ? "0" : "1";
                            if (c.join("") !== "000") whFilters.setF("categories", c.join(""));
                        } }
                Choice { shell: win.shell; label: "Purity"; value: win.shell.wh.purity
                        options: [["100", "SFW"], ["110", "+ Sketchy"], ["111", "+ NSFW"]]
                        onPicked: v => {
                            if (v === "111" && !win.shell.whHasKey) {
                                // в DMS ключ вводят на странице плагина, у своего запуска он в config.json
                                win.whStatus = win.shell.hosted
                                    ? win.shell.tr("wallhaven serves NSFW only with an API key: add %1 to %2", win.shell.tr("wallhaven API key"), "DMS → Plugins → Skindancer")
                                    : win.shell.tr("wallhaven serves NSFW only with an API key: add %1 to %2", "\"wallhaven_apikey\"", "~/.config/oboi/config.json");
                                return;
                            }
                            whFilters.setF("purity", v);
                        } }
            }
        }

        ListView {
            id: list
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; verticalCenterOffset: -20 }
            height: win.cardH
            // лента – источник выбора для всех видов; в других видах она просто не видна
            opacity: win.view === "slices" && win.source === "local" ? 1 : 0
            enabled: win.view === "slices" && win.source === "local"
            Behavior on opacity { NumberAnimation { duration: 200 } }
            orientation: ListView.Horizontal
            spacing: -Math.round(win.cardH * win.skew * 0.5)   // полоски чуть наезжают друг на друга
            model: win.shown
            cacheBuffer: win.width
            boundsBehavior: Flickable.StopAtBounds
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: width / 2 - win.cardW / 2
            preferredHighlightEnd: width / 2 + win.cardW / 2
            highlightMoveDuration: win.jumping ? 0 : 420     // встать на текущие обои при открытии сразу, без проезда
            highlightMoveVelocity: -1
            interactive: false
            // пустые поля по краям, чтобы и первая, и последняя карточка вставали по центру
            header: Item { width: list.width / 2 - win.cardW / 2; height: 1 }
            footer: Item { width: list.width / 2 - win.cardW / 2; height: 1 }
            function step(d) {
                win.userAct();
                if (list.count === 0) return;
                list.currentIndex = Math.max(0, Math.min(list.count - 1, list.currentIndex + d));
            }
            // Колесо и тачпад: копим смещение и листаем по одному шагу на каждые 120 единиц,
            // иначе тачпад с мелкими событиями пролистывал бы по карточке на каждое касание
            property real wheelAcc: 0
            function wheel(w) {
                const d = Math.abs(w.angleDelta.x) > Math.abs(w.angleDelta.y) ? w.angleDelta.x : w.angleDelta.y;
                wheelAcc += d;
                while (wheelAcc <= -120) { step(1); wheelAcc += 120; }
                while (wheelAcc >= 120) { step(-1); wheelAcc -= 120; }
            }

            delegate: Item {
                id: slot
                required property var modelData
                required property int index
                readonly property bool isCur: ListView.isCurrentItem
                readonly property bool near: Math.abs(index - list.currentIndex) < 14
                width: isCur ? win.cardW : win.sliverW
                height: list.height
                z: isCur ? 100 : 50 - Math.abs(index - list.currentIndex)
                // упругое «желе» при смене ширины
                Behavior on width { SpringAnimation { spring: 2.4; damping: win.shell.jelly ? 0.22 : 1.0; epsilon: 0.4 } }

                Card { anchors.fill: parent; win: pickerWin; entry: slot.modelData; isCur: slot.isCur; load: slot.near; skew: win.skew }
                MouseArea {
                    anchors.fill: parent
                    z: -1           // под карточкой, чтобы звезда избранного получала свой клик
                    // клик считается только внутри скошенной карточки, прозрачные углы отдают его соседке
                    containmentMask: QtObject {
                        function contains(p: point): bool {
                            const t = p.y / slot.height, off = slot.height * win.skew;
                            return p.y >= 0 && p.y <= slot.height && p.x >= off * (1 - t) && p.x <= slot.width - off * t;
                        }
                    }
                    onClicked: slot.isCur ? win.apply() : (win.userAct(), list.currentIndex = slot.index)
                    onWheel: w => list.wheel(w)
                }
            }
        }

        // ── Стена: сетка 16:9, выбор общий с лентой ──
        GridView {
            id: grid
            readonly property int cols: 5
            visible: win.view === "wall" && win.source === "local"
            anchors { left: parent.left; right: parent.right; leftMargin: win.width * 0.08; rightMargin: win.width * 0.08
                      top: swatches.bottom; topMargin: 26; bottom: parent.bottom; bottomMargin: 210 }
            clip: true
            cellWidth: Math.floor(width / cols)
            cellHeight: Math.round(cellWidth * 9 / 16) + 14
            model: win.view === "wall" ? win.shown : []
            cacheBuffer: cellHeight * 4
            boundsBehavior: Flickable.StopAtBounds
            // сетка сама не прокручивается: колесо и стрелки двигают выбор, а вид плавно едет за ним
            interactive: false
            Behavior on contentY { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            MouseArea { anchors.fill: parent; z: -2; acceptedButtons: Qt.NoButton; onWheel: w => win.gridWheel(w) }
            Connections {
                target: list
                function onCurrentIndexChanged() { if (win.view === "wall") grid.positionViewAtIndex(list.currentIndex, GridView.Contain); }
            }
            onVisibleChanged: if (visible) Qt.callLater(() => positionViewAtIndex(list.currentIndex, GridView.Center))
            delegate: Item {
                id: cell
                required property var modelData
                required property int index
                readonly property bool isCur: index === list.currentIndex
                width: grid.cellWidth; height: grid.cellHeight
                // прыжок на новую клетку: подскок и приземление с отскоком
                property real hop: 0
                onIsCurChanged: if (isCur && win.shell.jelly) hopAnim.restart()
                SequentialAnimation {
                    id: hopAnim
                    NumberAnimation { target: cell; property: "hop"; to: -16; duration: 110; easing.type: Easing.OutQuad }
                    NumberAnimation { target: cell; property: "hop"; to: 0; duration: 420; easing.type: Easing.OutBounce }
                }
                Card {
                    anchors { fill: parent; margins: 7 }
                    transform: Translate { y: cell.hop }
                    win: pickerWin; entry: cell.modelData; isCur: cell.isCur; skew: 0; radius: 14
                    dim: !cell.isCur && !hover.hovered
                    scale: cell.isCur ? 1.04 : hover.hovered ? 1.02 : 1
                    z: cell.isCur ? 2 : 0
                    Behavior on scale { SpringAnimation { spring: 3; damping: 0.3 } }
                }
                HoverHandler { id: hover }
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.LeftButton
                            onClicked: cell.isCur ? win.apply() : (win.userAct(), list.currentIndex = cell.index)
                            onWheel: w => win.gridWheel(w) }
            }
        }

        // ── Глубина: карточки уходят вдаль по обе стороны, позиция плавает упруго ──
        Item {
            id: depth
            visible: win.view === "depth" && win.source === "local"
            anchors { left: parent.left; right: parent.right; verticalCenter: list.verticalCenter }
            height: win.cardH
            property real pos: list.currentIndex
            Behavior on pos { SpringAnimation { spring: 2.2; damping: win.shell.jelly ? 0.2 : 0.45; epsilon: 0.002 } }
            // желе: пока позиция догоняет выбор (и перелетает его), карточки тянутся вширь и проседают
            readonly property real lag: list.currentIndex - pos
            readonly property real stretch: win.shell.jelly ? Math.min(0.18, Math.abs(lag) * 0.14) : 0
            readonly property real f: 0.55           // как быстро карточки уменьшаются с удалением
            readonly property int base: Math.round(pos) - 7
            MouseArea { anchors.fill: parent; onWheel: w => list.wheel(w) }
            Repeater {
                model: 15                              // постоянные ячейки: картинки в них меняются, ячейки нет
                delegate: Item {
                    id: d
                    required property int index
                    readonly property int idx: depth.base + index
                    readonly property bool valid: idx >= 0 && idx < win.shown.length
                    readonly property real n: idx - depth.pos
                    readonly property real an: Math.abs(n)
                    readonly property real sc: 1 / (1 + depth.f * an)
                    readonly property real off: (n < 0 ? -1 : 1) * Math.log(1 + depth.f * an) / depth.f
                    visible: valid && an < 6.5
                    width: win.cardW; height: win.cardH
                    x: depth.width / 2 - width / 2 + off * win.cardW * 0.62
                    y: 0
                    scale: sc
                    opacity: 1 - Math.max(0, Math.min(1, (an - 4.5) / 2))
                    z: 100 - an * 10
                    Card {
                        anchors.fill: parent
                        win: pickerWin; entry: d.valid ? win.shown[d.idx] : null; isCur: d.idx === list.currentIndex
                        skew: win.skew + (win.shell.jelly ? Math.max(-0.08, Math.min(0.08, depth.lag * 0.06)) : 0)
                        dim: d.an > 0.5
                        transform: Scale { origin.x: d.width / 2; origin.y: d.height
                                           xScale: 1 + depth.stretch; yScale: 1 - depth.stretch * 0.45 }
                    }
                    MouseArea { anchors.fill: parent; enabled: d.valid; z: -1
                                onClicked: d.idx === list.currentIndex ? win.apply() : (win.userAct(), list.currentIndex = d.idx)
                                onWheel: w => list.wheel(w) }
                }
            }
        }

        // ── wallhaven: сетка результатов, следующая страница при прокрутке к концу ──
        GridView {
            id: whGrid
            visible: win.source === "wallhaven"
            anchors { left: parent.left; right: parent.right; leftMargin: win.width * 0.08; rightMargin: win.width * 0.08
                      top: whFilters.bottom; topMargin: 22; bottom: parent.bottom; bottomMargin: 210 }
            clip: true
            cellWidth: Math.floor(width / 5)
            cellHeight: Math.round(cellWidth * 9 / 16) + 14
            model: win.whItems
            boundsBehavior: Flickable.StopAtBounds
            interactive: false
            cacheBuffer: cellHeight * 4
            Behavior on contentY { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Connections { target: win; function onWhIndexChanged() { whGrid.positionViewAtIndex(win.whIndex, GridView.Contain); if (win.whItems.length > 0 && win.whIndex >= win.whItems.length - 5) win.whMore(); } }
            delegate: Item {
                id: wc
                required property var modelData
                required property int index
                readonly property bool isCur: index === win.whIndex
                width: whGrid.cellWidth; height: whGrid.cellHeight
                property real hop: 0
                onIsCurChanged: if (isCur && win.shell.jelly) whHop.restart()
                SequentialAnimation {
                    id: whHop
                    NumberAnimation { target: wc; property: "hop"; to: -16; duration: 110; easing.type: Easing.OutQuad }
                    NumberAnimation { target: wc; property: "hop"; to: 0; duration: 420; easing.type: Easing.OutBounce }
                }
                Rectangle {
                    anchors { fill: parent; margins: 7 }
                    transform: Translate { y: wc.hop }
                    radius: 14; clip: true; color: "#11161c"
                    border.color: wc.isCur ? win.shell.gold : Qt.rgba(1, 1, 1, 0.10); border.width: wc.isCur ? 2 : 1
                    scale: wc.isCur ? 1.04 : 1
                    Behavior on scale { SpringAnimation { spring: 3; damping: 0.3 } }
                    Image { anchors { fill: parent; margins: 2 }
                            source: wc.modelData.thumb; fillMode: Image.PreserveAspectCrop
                            asynchronous: true; opacity: wc.isCur ? 1 : 0.7 }
                    Text { visible: win.whSaved[wc.modelData.id] === true; text: win.shell.tr("Saved"); color: win.shell.gold
                           font.family: win.shell.serif; font.pixelSize: 13; anchors { left: parent.left; bottom: parent.bottom; margins: 10 } }
                }
                MouseArea { anchors.fill: parent; onClicked: wc.isCur ? win.whSave() : (win.whIndex = wc.index)
                            onWheel: w => win.gridWheel(w) }
            }
        }
        Column {
            visible: win.source === "wallhaven"
            anchors { horizontalCenter: parent.horizontalCenter; top: whGrid.bottom; topMargin: 18 }
            spacing: 8
            Text { anchors.horizontalCenter: parent.horizontalCenter
                   text: win.whStatus || (win.whChosen ? win.whChosen.resolution + "  ·  " + (win.whChosen.category || "") + "  ·  " + win.shell.tr("Enter: save to wallpapers") : "")
                   font.family: win.shell.serif; font.pixelSize: 16; color: win.shell.ink }
            Text { anchors.horizontalCenter: parent.horizontalCenter
                   text: (win.whTotal ? win.shell.tr("%1 found", win.whTotal) + "  ·  " : "") + win.shell.tr("Queries work best in English: lighthouse, desert, rain")
                   font.family: win.shell.serif; font.pixelSize: 13; color: win.shell.inkDim; opacity: 0.8 }
        }

        // Переключатель видов
        Row {
            id: viewBar
            anchors { right: parent.right; rightMargin: 60; verticalCenter: searchBox.verticalCenter }
            spacing: 16
            Repeater {
                model: win.views
                delegate: Text {
                    required property var modelData
                    readonly property bool on: win.source === "local" && win.view === modelData[0]
                    text: win.shell.tr(modelData[1])
                    font.family: win.shell.serif; font.pixelSize: 15; font.italic: on
                    color: on ? win.shell.gold : win.shell.inkDim
                    opacity: on ? 1 : 0.7
                    MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: { win.source = "local"; win.view = parent.modelData[0]; } }
                }
            }
            Text { visible: win.shell.whEnabled; text: "·"; color: win.shell.inkDim; font.pixelSize: 15 }
            Text {
                visible: win.shell.whEnabled
                text: "wallhaven"
                font.family: win.shell.serif; font.pixelSize: 15; font.italic: win.source === "wallhaven"
                color: win.source === "wallhaven" ? win.shell.gold : win.shell.inkDim
                opacity: win.source === "wallhaven" ? 1 : 0.7
                MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: win.source = win.source === "wallhaven" ? "local" : "wallhaven" }
            }
            Image {
                source: Qt.resolvedUrl("icons/gear.svg"); sourceSize: Qt.size(20, 20); width: 20; height: 20
                anchors.verticalCenter: parent.verticalCenter
                opacity: win.settingsOpen ? 1 : 0.7
                rotation: win.settingsOpen ? 60 : 0
                Behavior on rotation { SpringAnimation { spring: 3; damping: 0.3 } }
                MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: win.settingsOpen = !win.settingsOpen }
            }
            Image {
                source: Qt.resolvedUrl("icons/help.svg"); sourceSize: Qt.size(20, 20); width: 20; height: 20
                anchors.verticalCenter: parent.verticalCenter; opacity: 0.7
                MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: win.shell.helpScreen = win.screen }
            }
        }

        // Подпись под лентой
        Column {
            visible: win.source === "local" && win.shell.captions
            anchors { horizontalCenter: parent.horizontalCenter; top: win.view === "wall" ? grid.bottom : list.bottom; topMargin: win.view === "wall" ? 18 : 30 }
            width: Math.min(win.cardW * 1.1, win.width * 0.8)
            spacing: 8
            Text {
                width: parent.width; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                textFormat: Text.PlainText
                text: win.chosen ? win.chosen.title : ""
                font.family: win.shell.serif; font.pixelSize: 24; font.italic: true; color: win.shell.ink
            }
            Text {
                width: parent.width; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight
                visible: win.view !== "wall"       // под стеной места мало: там только название
                textFormat: Text.PlainText
                text: win.chosen ? (win.chosen.description || "") : ""
                font.family: win.shell.serif; font.pixelSize: 15; color: win.shell.inkDim
            }
            Text {
                width: parent.width; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                visible: win.view !== "wall"
                textFormat: Text.PlainText
                text: win.chosen ? [win.chosen.w + "×" + win.chosen.h, win.chosen.style].concat((win.chosen.keywords || []).slice(0, 5)).filter(s => s).join("  ·  ") : ""
                font.family: win.shell.serif; font.pixelSize: 13; color: win.shell.gold; opacity: 0.85
            }
        }

        Text {
            visible: win.shell.hints
            // в DMS док обычно стоит внизу и закрыл бы подсказки
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: win.shell.hosted ? 96 : 40 }
            text: [win.gridMode ? win.shell.tr("← → ↑ ↓ move by cells") : win.shell.tr("← → browse"),
                   win.source === "wallhaven" ? win.shell.tr("Enter save") : win.shell.tr("Enter apply"),
                   win.shell.tr("Ctrl+D favorite"), win.shell.tr("Ctrl+1 2 3 view"), win.shell.tr("Ctrl+4 wallhaven"),
                   win.shell.tr("F1 help"), win.shell.tr("Esc close")]
                  .filter((h, i) => i !== 2 || win.source !== "wallhaven")       // на вкладке wallhaven избранного нет
                  .join("   ·   ")
            font.family: win.shell.serif; font.pixelSize: 13; color: win.shell.inkDim; opacity: 0.7
        }
    }

    // ── Настройки «Обоев»: пишутся в ~/.config/oboi/config.json сразу при выборе ──
    Rectangle {
        id: settingsPanel
        z: 500
        visible: opacity > 0
        opacity: win.settingsOpen && win.open && !win.busy ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        anchors { right: parent.right; rightMargin: 48; top: parent.top; topMargin: Math.round(win.height * 0.24) }
        width: setCol.implicitWidth + 48
        height: setCol.implicitHeight + 44
        radius: 24
        color: win.shell.panel
        border.color: Qt.rgba(0.91, 0.78, 0.60, 0.30); border.width: 1
        MouseArea { anchors.fill: parent }          // клики по панели не закрывают ленту
        Column {
            id: setCol
            anchors { left: parent.left; top: parent.top; margins: 24 }
            spacing: 12
            readonly property int lw: 160
            readonly property int fw: 200
            Text { text: win.shell.tr("Settings"); font.family: win.shell.serif; font.pixelSize: 22; font.italic: true; color: win.shell.gold }
            Text { visible: win.shell.cfgBroken; text: win.shell.tr("Error: %1", win.shell.cfgDir + "/config.json")
                   font.family: win.shell.serif; font.pixelSize: 14; color: "#e8a08a" }
            Choice { shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "Transition"; ctx: "transition"; value: win.shell.transitionPref
                    options: [["random", "Random"], ["grow", "Grow"], ["iris", "Iris"], ["dissolve", "Dissolve"],
                              ["melt", "Melt"], ["ink", "Ink"], ["none", "None"]]
                    onPicked: v => win.shell.setCfg("transition", v) }
            Choice { shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "View on open"; value: win.shell.startView
                    options: [["last", "Last used"], ["slices", "Strip"], ["wall", "Wall"], ["depth", "Depth"]]
                    onPicked: v => win.shell.setCfg("view", v) }
            Choice { shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "Bounce"; value: win.shell.jelly
                    options: [[true, "Jelly"], [false, "Calm"]]; onPicked: v => win.shell.setCfg("jelly", v) }
            Choice { shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "Captions"; value: win.shell.captions
                    options: [[true, "Show"], [false, "Hide"]]; onPicked: v => win.shell.setCfg("captions", v) }
            Choice { shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "Key hints"; value: win.shell.hints
                    options: [[true, "Show"], [false, "Hide"]]; onPicked: v => win.shell.setCfg("hints", v) }
            Choice { shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "Semantic search"; value: win.shell.semEnabled
                    options: [[true, "On"], [false, "Off"]]; onPicked: v => win.shell.setCfg("semantic", v) }
            Choice { shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "wallhaven"; value: win.shell.whEnabled
                    options: [[true, "Show tab"], [false, "Hide tab"]]
                    onPicked: v => { win.shell.setCfg("wallhaven", v); if (!v) win.source = "local"; } }
            Choice { visible: !win.shell.hosted       // в DMS язык берётся из настроек самой оболочки
                    shell: win.shell; labelW: setCol.lw; fieldW: setCol.fw; label: "Language"; value: win.shell.cfg.language || "auto"
                    options: [["auto", "Auto"], ["en", "English"], ["ru", "Русский"], ["de", "Deutsch"], ["es", "Español"],
                              ["fr", "Français"], ["it", "Italiano"], ["pt_BR", "Português (BR)"], ["nl", "Nederlands"],
                              ["pl", "Polski"], ["uk", "Українська"], ["tr", "Türkçe"], ["ja", "日本語"], ["ko", "한국어"],
                              ["zh_CN", "简体中文"]]
                    onPicked: v => win.shell.setCfg("language", v) }
            Text { text: win.shell.tr("wallhaven filters are in the wallhaven tab, under the search field.")
                   font.family: win.shell.serif; font.pixelSize: 13; color: win.shell.inkDim; opacity: 0.8 }
        }
    }

    // ── Переход: выбранная карточка упруго раздувается на весь экран ──
    Item {
        id: morph
        property bool running: false
        property bool covering: false
        property string path: ""
        property real k: win.skew
        property real r: 18
        x: 0; y: 0; width: 0; height: 0
        visible: running
        z: 1000

        function reset() { grow.stop(); running = false; covering = false; opacity = 1; }
        function start(p, x0, y0, w0, h0) {
            path = p; k = win.skew; r = 18; opacity = 1;
            morph.x = x0; morph.y = y0; morph.width = w0; morph.height = h0;
            running = true; covering = true;
            grow.restart();
        }

        Item {
            id: full
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Image { anchors.fill: parent; source: win.shell.fileUrl(morph.path); fillMode: Image.PreserveAspectCrop
                    asynchronous: false; sourceSize.width: win.width; smooth: true }
        }
        Slant { id: morphShape; anchors.fill: parent; skew: morph.k; radius: morph.r; visible: false; layer.enabled: true }
        MultiEffect { anchors.fill: parent; source: full; maskEnabled: true; maskSource: morphShape; maskThresholdMin: 0.5; maskSpreadAtMin: 1.0 }

        SequentialAnimation {
            id: grow
            ParallelAnimation {
                SpringAnimation { target: morph; property: "x"; to: 0; spring: 1.7; damping: 0.24; epsilon: 0.5 }
                SpringAnimation { target: morph; property: "y"; to: 0; spring: 1.7; damping: 0.24; epsilon: 0.5 }
                SpringAnimation { target: morph; property: "width"; to: win.width; spring: 1.7; damping: 0.24; epsilon: 0.5 }
                SpringAnimation { target: morph; property: "height"; to: win.height; spring: 1.7; damping: 0.24; epsilon: 0.5 }
                NumberAnimation { target: morph; property: "k"; to: 0; duration: 520; easing.type: Easing.OutBack }
                NumberAnimation { target: morph; property: "r"; to: 0; duration: 520; easing.type: Easing.OutCubic }
            }
            ScriptAction { script: win.handoff(morph.path, false) }
        }
    }

    // ── Переход-шейдер: старые обои → новые поверх всего экрана, DMS меняет обои под ним ──
    Item {
        id: fx
        anchors.fill: parent
        visible: running
        z: 1001
        property bool running: false
        property string kind: "iris"
        property string fromPath: ""
        property string toPath: ""
        property real progress: 0

        function reset() { run.stop(); running = false; progress = 0; opacity = 1; }
        function start(k, from, to) {
            kind = k; fromPath = from; toPath = to; progress = 0; opacity = 1; running = true;
            waitLoad.restart();
        }
        // Картинки готовим заранее, пока лента открыта: текущие обои сразу, выбранную через 250 мс
        // после остановки. Иначе 4K-файл грузится уже после Enter, и полсекунды экран стоит.
        Timer { id: preload; interval: 250; onTriggered: if (!fx.running && win.chosen) fx.toPath = win.chosen.path }
        Connections {
            target: win
            function onChosenChanged() { if (win.open && !fx.running) preload.restart(); }
            function onOpenChanged() { if (win.open && !fx.running) { fx.fromPath = win.shell.current; preload.restart(); } }
        }
        Connections {
            target: win.shell
            function onCurrentChanged() { if (win.open && !fx.running) fx.fromPath = win.shell.current; }
        }
        // ждём, пока обе картинки загрузятся, иначе первый кадр будет пустым
        Timer {
            id: waitLoad; interval: 30; repeat: true
            property int tries: 0
            onRunningChanged: if (running) tries = 0
            onTriggered: {
                tries++;
                // новая картинка не грузится (Qt не знает формат, файл битый): обои ставим без перехода
                if (toImg.status === Image.Error || (tries > 60 && toImg.status !== Image.Ready)) {
                    stop(); const t = fx.toPath; fx.reset();
                    win.setWp(t); win.busy = false; win.shell.pickerScreen = null;
                    return;
                }
                if ((fromImg.status === Image.Ready && toImg.status === Image.Ready) || tries > 60) { stop(); run.restart(); }
            }
        }

        Item { id: fromItem; anchors.fill: parent; visible: false; layer.enabled: true
            Image { id: fromImg; anchors.fill: parent; source: win.shell.fileUrl(fx.fromPath)
                    fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: win.width; smooth: true } }
        Item { id: toItem; anchors.fill: parent; visible: false; layer.enabled: true
            Image { id: toImg; anchors.fill: parent; source: win.shell.fileUrl(fx.toPath)
                    fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: win.width; smooth: true } }

        ShaderEffect {
            anchors.fill: parent
            property variant fromTex: fromItem
            property variant toTex: toItem
            property real progress: fx.progress
            property real aspect: width / Math.max(1, height)
            property real seed: 0
            property color glow: win.shell.gold
            fragmentShader: Qt.resolvedUrl("shaders/" + fx.kind + ".frag.qsb")
            Component.onCompleted: seed = Math.random()
            onVisibleChanged: if (visible) seed = Math.random()
        }

        SequentialAnimation {
            id: run
            // DMS получает новые обои в начале анимации: его собственный переход идёт под непрозрачным оверлеем
            ScriptAction { script: win.setWp(fx.toPath) }
            NumberAnimation { target: fx; property: "progress"; from: 0; to: 1; duration: fx.kind === "melt" ? 1900 : 1600
                              easing.type: Easing.InOutSine }
            ScriptAction { script: win.handoff(fx.toPath, true) }
        }
    }
}
