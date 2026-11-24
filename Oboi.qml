// Ядро «Обоев»: меню по правому клику, лента выбора, переводы, настройки, IPC.
// Два хозяина. Самостоятельно (shell.qml, qs -c oboi): обои через `dms ipc`, настройки в
// ~/.config/oboi/config.json. Плагином DMS (OboiDaemon.qml): hosted = true, обои, настройки
// и переводы идут через объект host, который передаёт демон.
import QtCore
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // ── Хозяин ──
    property bool hosted: false
    property var host: null             // { setWallpaper(path), save(key, value), tr(text, ctx) }
    property var hostCfg: null          // настройки плагина из DMS
    property string hostCurrent: ""     // SessionData.wallpaperPath
    onHostCurrentChanged: if (hosted) current = hostCurrent

    readonly property string home: Quickshell.env("HOME")
    // Плагин и самостоятельный запуск держат индекс и миниатюры порознь: у них могут быть разные папки,
    // и общий индекс они бы переписывали друг у друга. Помощникам папку передаёт OBOI_CACHE.
    readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || home + "/.cache") + (hosted ? "/oboi/dms" : "/oboi")
    readonly property string indexPath: cacheDir + "/index.json"
    function cacheArgs() { return ["--out", indexPath, "--thumbs", cacheDir + "/thumbs"]; }
    readonly property string indexer: shellDir + "/bin/oboi-index"

    // Палитра: тёплое золото на тёмном небе, в духе Дали
    readonly property color gold: "#e9c79a"
    readonly property color ink: "#f1e6d6"
    readonly property color inkDim: "#b9aa98"
    readonly property color panel: Qt.rgba(0.07, 0.10, 0.13, 0.86)
    readonly property string serif: "Noto Serif"
    
    property var items: []            // всё из индекса, кроме портретных
    property string current: ""       // путь текущих обоев
    property var menuScreen: null
    property real menuX: 0
    property real menuY: 0
    property var pickerScreen: null
    // Экран, к которому относится действие: где открыта лента или меню «случайные обои».
    // От него зависят текущие обои, папка по умолчанию и монитор, на который ставятся обои.
    property var randomScreen: null
    readonly property var targetScreen: pickerScreen || randomScreen || Quickshell.screens[0] || null
    readonly property string targetName: targetScreen ? targetScreen.name : ""
    property var helpScreen: null

    // Настройки «Обоев»: $XDG_CONFIG_HOME/oboi/config.json. Правятся в ленте (шестерёнка) или руками.
    readonly property string cfgDir: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/oboi"
    property var fileCfg: ({})
    readonly property var cfg: hosted ? (hostCfg || ({})) : fileCfg
    readonly property string transitionPref: cfg.transition || "random"
    readonly property bool semEnabled: cfg.semantic !== false
    readonly property bool jelly: cfg.jelly !== false                 // упругость карточек и прыжок выбора
    readonly property bool hints: cfg.hints !== false                 // строка подсказок внизу ленты
    readonly property bool captions: cfg.captions !== false           // название и описание под карточкой
    readonly property bool whEnabled: cfg.wallhaven !== false          // вкладка wallhaven
    readonly property string startView: cfg.view || "last"          // last: тот, что был в прошлый раз
    readonly property var wh: Object.assign({ atleast: "3840x2160", ratios: "16x9,16x10", categories: "111",
                                              purity: "100", sorting: "" }, cfg.wh || {})
    readonly property bool whHasKey: !!cfg.wallhaven_apikey
    // папки обоев: из настроек; в плагине по умолчанию папка текущих обоев
    // В DMS обоями бывает цвет (#223344) или пусто: тогда папка картинок по XDG, а не относительный путь
    readonly property string picturesDir: {
        const u = StandardPaths.writableLocation(StandardPaths.PicturesLocation).toString();
        return u ? decodeURIComponent(u.replace(/^file:\/\//, "")) : home + "/Pictures";
    }
    readonly property string defaultDir: hosted ? (hostCurrent.startsWith("/") ? hostCurrent.replace(/\/[^\/]*$/, "") : picturesDir)
                                                : picturesDir
    // путь → адрес для Image.source: каждый кусок кодируется, иначе #, ? и % в имени ломают картинку
    function fileUrl(p) { return p ? "file://" + p.split("/").map(encodeURIComponent).join("/") : ""; }
    readonly property var dirs: (cfg.dirs && cfg.dirs.length ? cfg.dirs : [defaultDir]).map(d => d.replace(/^~/, home))
    readonly property string saveDir: dirs[0]
    function dirArgs() { let a = []; dirs.forEach(d => { a.push("--dir"); a.push(d); }); return a; }
    readonly property string fetcher: shellDir + "/bin/oboi-fetch"
    readonly property string semantic: shellDir + "/bin/oboi-semantic"
    // ключ wallhaven помощнику передаём переменной окружения: в плагине config.json нет
    readonly property var fetchEnv: cfg.wallhaven_apikey ? ({ OBOI_WALLHAVEN_KEY: cfg.wallhaven_apikey }) : ({})
    // ловушка правого клика: у самостоятельного запуска всегда, в плагине по настройке (DMS тогда выключает своё меню)
    readonly property bool catcherOn: hosted ? cfg.catcher === true : true
    property bool cfgBroken: false      // config.json есть, но не читается: не пишем поверх, иначе потеряем dirs и ключ
    function setCfg(key, value) {
        if (hosted) { host.save(key, value); return; }
        if (cfgBroken) return;
        const c = Object.assign({}, fileCfg); c[key] = value; fileCfg = c;
        cfgFile.setText(JSON.stringify(c, null, 2) + "\n");
    }
    function setWh(key, value) { const w = Object.assign({}, wh); w[key] = value; setCfg("wh", w); }
    readonly property bool indexing: reindex.running   // при первом открытии список ещё пуст, это не «ничего»
    function reindexNow() { if (!reindex.running) reindex.running = true; }

    // ── Переводы: формат DMS, translations/<язык>.json, ключ английский, внутри {контекст: перевод} ──
    // Язык: "language" в config.json или из LC_ALL / LC_MESSAGES / LANG; нет файла, значит английский.
    readonly property var langFiles: ["ru", "de", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt_BR", "tr", "uk", "zh_CN"]
    readonly property string shellDir: Qt.resolvedUrl(".").toString().replace(/^file:\/\//, "").replace(/\/$/, "")
    readonly property string lang: {
        const want = cfg.language && cfg.language !== "auto" ? cfg.language
                   : (Quickshell.env("LC_ALL") || Quickshell.env("LC_MESSAGES") || Quickshell.env("LANG") || "en").split(".")[0];
        if (want === "en" || langFiles.indexOf(want) !== -1) return want;
        const two = want.split("_")[0];
        return langFiles.find(l => l.split("_")[0] === two) || "en";
    }
    property var dict: ({})
    FileView {
        id: trFile
        path: root.hosted || root.lang === "en" ? "" : root.shellDir + "/translations/" + root.lang + ".json"
        watchChanges: true
        onFileChanged: reload()
        onPathChanged: if (!path) root.dict = {}
        onLoaded: { try { root.dict = JSON.parse(text()) || {}; } catch (e) { root.dict = {}; } }
        onLoadFailed: root.dict = {}
    }
    function trc(text, ctx) {
        if (hosted && host) return host.tr(text, ctx);
        // формат DMS: {контекст: {английская строка: перевод}}
        const b = dict[ctx], own = dict[text];
        return (b && b[text]) || (own && own[text]) || text;
    }
    function tr(text) {
        let t = trc(text, text);
        for (let i = 1; i < arguments.length; i++) t = t.replace("%" + i, arguments[i]);
        return t;
    }
    Component.onCompleted: if (!hosted) Quickshell.execDetached(["mkdir", "-p", cfgDir])
    FileView {
        id: cfgFile
        path: root.hosted ? "" : root.cfgDir + "/config.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.fileCfg = JSON.parse(text()) || {}; root.cfgBroken = false; }
            catch (e) { root.fileCfg = {}; root.cfgBroken = text().trim() !== ""; }
        }
        onLoadFailed: { root.fileCfg = {}; root.cfgBroken = false; }
    }

    property var favs: ({})           // путь → true; живёт отдельно, чтобы звезда не перестраивала ленту
    property string itemsSig: ""

    readonly property bool tallTarget: !!targetScreen && targetScreen.height > targetScreen.width
    onTallTargetChanged: if (itemsSig !== "") loadIndex()
    function loadIndex() {
        let vis = [];
        try {
            // вертикальные картинки только на вертикальном экране; записи пропавшей папки (missing) не показываем
            const tall = tallTarget;
            vis = (JSON.parse(indexFile.text()).items || []).filter(e => !e.missing && !!e.portrait === tall);
        } catch (e) {
            vis = [];
        }
        const f = {};
        vis.forEach(e => { if (e.favorite) f[e.path] = true; });
        favs = f;
        // список заменяем, только если поменялся состав картинок: иначе лента сбросила бы выбор
        const sig = vis.map(e => [e.path, e.key, e.title, e.description, (e.keywords || []).join(","), (e.tags || []).join(",")].join("|")).join("\n");
        if (sig !== itemsSig) { itemsSig = sig; items = vis; }
    }

    function toggleFavorite(path) {
        const f = Object.assign({}, favs);
        if (f[path]) delete f[path]; else f[path] = true;
        favs = f;
        Quickshell.execDetached([indexer, "--quiet", "--favorite", path, f[path] ? "on" : "off"].concat(cacheArgs(), dirArgs()));
    }

    // ── Смысловой поиск: тёплый помощник oboi-semantic serve, ответы строками JSON ──
    property bool semReady: false
    property var semScores: ({})      // путь → близость к последнему запросу
    property string semQuery: ""
    property int semId: 0
    // Помощник держит модель в памяти (около 0,5 ГБ), поэтому живёт, пока открыта лента,
    // и ещё три минуты после: повторное открытие не ждёт холодного старта.
    property bool semHold: false
    onPickerScreenChanged: { if (pickerScreen !== null) { semHold = true; semIdle.stop(); } else semIdle.restart(); }
    Timer { id: semIdle; interval: 180000; onTriggered: root.semHold = false }
    Process {
        id: sem
        command: [root.semantic, "serve"]
        environment: ({ OBOI_CACHE: root.cacheDir })
        stdinEnabled: true
        running: root.semHold && root.semEnabled
        stdout: SplitParser {
            onRead: line => {
                let m;
                try { m = JSON.parse(line); } catch (e) { return; }
                if (m.ready) {
                    root.semReady = true;
                    if (root.semPendingQ) { const q = root.semPendingQ; root.semPendingQ = ""; root.semAsk(q); }
                    return;
                }
                if (m.id !== root.semId || !m.results) return;
                const sc = {};          // порог и поправку на «магниты» уже применил помощник
                m.results.forEach(r => sc[r[0]] = r[1]);
                root.semScores = sc; root.semQuery = m.q;
            }
        }
        onExited: root.semReady = false      // нет модели или пакетов: остаётся поиск по словам
    }
    property string semPendingQ: ""     // запрос, пришедший до готовности помощника; задаём его по сигналу ready
    function semAsk(q) {
        if (!semReady) { semPendingQ = q; return; }
        semId += 1;
        sem.write(JSON.stringify({ id: semId, q: q, n: 40 }) + "\n");
    }
    // векторы новых картинок считаются в фоне после индекса, с пониженным приоритетом
    Process { id: semIndex; command: [root.semantic, "index", "--quiet"]; environment: ({ OBOI_CACHE: root.cacheDir }) }

    function setWallpaper(path) {
        if (hosted) host.setWallpaper(path, targetName);
        else Quickshell.execDetached(["dms", "ipc", "call", "wallpaper", "set", path]);
        current = path;
    }

    // экран с фокусом: в плагине его знает DMS для любого композитора; иначе первый
    function focusedScreen() {
        const name = hosted && host && host.focusedScreen ? host.focusedScreen() : "";
        return Quickshell.screens.find(s => s.name === name) || Quickshell.screens[0];
    }

    function openMenu(screen, x, y) {
        menuScreen = screen; menuX = x; menuY = y;
    }

    function openPicker(screen) {
        menuScreen = null;
        reindexNow();
        if (hosted) current = hostCurrent; else currentProc.running = true;
        pickerScreen = screen || Quickshell.screens[0];
    }

    function randomWallpaper(screen) {
        if (items.length === 0) { reindexNow(); return; }
        randomScreen = screen || null;
        let pick = items[Math.floor(Math.random() * items.length)];
        if (pick.path === current && items.length > 1) pick = items[(items.indexOf(pick) + 1) % items.length];
        setWallpaper(pick.path);
        randomScreen = null;
    }

    FileView {
        id: indexFile
        path: root.indexPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.loadIndex()
    }

    // Индекс обновляется при каждом открытии ленты: новые картинки получают миниатюры
    Process {
        id: reindex
        command: [root.indexer, "--quiet"].concat(root.cacheArgs(), root.dirArgs())
        onExited: { indexFile.reload(); if (root.semEnabled && !semIndex.running) semIndex.running = true; }
    }

    Process {
        id: currentProc
        command: ["dms", "ipc", "call", "wallpaper", "get"]
        stdout: StdioCollector {
            onStreamFinished: root.current = this.text.trim()
        }
    }

    IpcHandler {
        // в DMS: dms ipc call skindancer …; сам по себе (qs -c oboi): qs -c oboi ipc call oboi …
        target: root.hosted ? "skindancer" : "oboi"
        function picker(): void { root.openPicker(root.focusedScreen()); }
        function random(): void { root.randomWallpaper(root.focusedScreen()); }
        function menuAt(x: real, y: real): void { root.openMenu(Quickshell.screens[0], x, y); }
        function close(): void { root.menuScreen = null; root.pickerScreen = null; }
        function next(): void { picker.stepBy(1); }
        function prev(): void { picker.stepBy(-1); }
        function apply(): void { picker.apply(); }
        function find(q: string): void { picker.setQuery(q); }
        function favorite(): void { picker.toggleFavorite(); }
        function favorites(): void { picker.favOnly = !picker.favOnly; }
        function hue(n: int): void { picker.hueFilter = n; }
        function transition(kind: string): void { picker.forcedKind = kind; }
        function view(name: string): void { picker.setView(name); }
        function source(name: string): void { picker.source = name; }
        function save(): void { picker.whSave(); }
        function help(): void { root.helpScreen = root.focusedScreen(); }
        function closeHelp(): void { root.helpScreen = null; }
        function cell(dx: int, dy: int): void { picker.moveCell(dx, dy); }
        function settings(): void { picker.settingsOpen = !picker.settingsOpen; }
        function set(key: string, value: string): void { root.setCfg(key, value === "true" ? true : value === "false" ? false : value); }
    }

    // ── Ловушка правого клика: слой фона под окнами, над обоями DMS ──
    Variants {
        model: root.catcherOn ? Quickshell.screens : []
        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData
                color: "transparent"
                WlrLayershell.namespace: "oboi:desktop-input"
                WlrLayershell.layer: WlrLayer.Background
                exclusionMode: ExclusionMode.Ignore
                anchors { top: true; bottom: true; left: true; right: true }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: mouse => root.openMenu(modelData, mouse.x, mouse.y)
                }
            }
        }
    }

    // ── Меню стола ──
    PanelWindow {
        id: menuWin
        visible: root.menuScreen !== null
        screen: root.menuScreen
        color: "transparent"
        WlrLayershell.namespace: "oboi:menu"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: root.menuScreen = null
        }

        Rectangle {
            id: card
            readonly property var entries: [
                { icon: "wallpaper", text: "Wallpapers…", act: () => root.openPicker(root.menuScreen) },
                { icon: "shuffle", text: "Random wallpaper", act: () => { const s = root.menuScreen; root.menuScreen = null; root.randomWallpaper(s); } },
                { icon: "widgets", text: "Desktop widgets", act: () => { root.menuScreen = null; Quickshell.execDetached(["dms", "ipc", "call", "settings", "openWith", "desktop_widgets"]); } },
                { icon: "tune", text: "Shell settings", act: () => { root.menuScreen = null; Quickshell.execDetached(["dms", "ipc", "call", "settings", "open"]); } },
                { icon: "help", text: "Help", act: () => { root.helpScreen = root.menuScreen; root.menuScreen = null; } }
            ]
            width: 290
            height: col.implicitHeight + 16
            x: Math.min(root.menuX, menuWin.width - width - 12)
            y: Math.min(root.menuY, menuWin.height - height - 12)
            radius: 22
            color: root.panel
            border.color: Qt.rgba(0.91, 0.78, 0.60, 0.28)
            border.width: 1
            scale: menuWin.visible ? 1 : 0.86
            opacity: menuWin.visible ? 1 : 0
            transformOrigin: Item.TopLeft
            Behavior on scale { SpringAnimation { spring: 4; damping: 0.32 } }
            Behavior on opacity { NumberAnimation { duration: 140 } }

            Column {
                id: col
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                spacing: 2
                Repeater {
                    model: card.entries
                    delegate: Rectangle {
                        required property var modelData
                        width: col.width
                        height: 42
                        radius: 16
                        color: hover.hovered ? Qt.rgba(0.91, 0.78, 0.60, 0.14) : "transparent"
                        HoverHandler { id: hover }
                        TapHandler { onTapped: modelData.act() }
                        Row {
                            anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 14 }
                            spacing: 12
                            Image { source: Qt.resolvedUrl("icons/" + modelData.icon + ".svg"); sourceSize: Qt.size(20, 20); width: 20; height: 20; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: root.tr(modelData.text); font.family: root.serif; font.pixelSize: 15; color: root.ink; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }
        }
        Item { focus: menuWin.visible; Keys.onEscapePressed: root.menuScreen = null }
    }

    // ── Справка ──
    Help { shell: root }

    // ── Лента выбора обоев ──
    Picker {
        id: picker
        shell: root
    }
}
