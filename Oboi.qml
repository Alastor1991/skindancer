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
    readonly property var targetScreen: randomScreen || pickerScreen || Quickshell.screens[0] || null
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
    // без настроенной папки: папка текущих обоев и <Картинки>/Wallpapers (туда же сохраняются картинки
    // с wallhaven, если в папку текущих обоев писать нельзя: /usr/share/backgrounds, /nix/store)
    readonly property var dirs: (cfg.dirs && cfg.dirs.length ? cfg.dirs
                                 : [defaultDir, picturesDir + "/Wallpapers"].filter((d, i, a) => a.indexOf(d) === i))
                                .map(d => d.replace(/^~/, home))
    readonly property string saveDir: dirs[0]
    function dirArgs() { let a = []; dirs.forEach(d => { a.push("--dir"); a.push(d); }); return a; }
    readonly property string fetcher: shellDir + "/bin/oboi-fetch"
    readonly property string semantic: shellDir + "/bin/oboi-semantic"
    // ключ wallhaven помощнику передаём переменной окружения: в плагине config.json нет
    // в плагине переменная есть всегда, даже пустая: тогда ключ из config.json своего запуска не подмешается
    readonly property var fetchEnv: hosted || cfg.wallhaven_apikey ? ({ OBOI_WALLHAVEN_KEY: cfg.wallhaven_apikey || "" }) : ({})
    // ловушка правого клика: у самостоятельного запуска всегда, в плагине по настройке (DMS тогда выключает своё меню)
    // На labwc, Sway, Scroll и KDE клики по пустому столу заняты композитором (DMS там тоже не ловит):
    // у самостоятельного запуска узнаём это по XDG_CURRENT_DESKTOP, в плагине решает OboiDaemon.
    readonly property bool desktopTaken: /labwc|sway|scroll|kde|kwin/i.test(Quickshell.env("XDG_CURRENT_DESKTOP") || "")
    readonly property bool catcherOn: hosted ? cfg.catcher === true : !desktopTaken
    property bool cfgBroken: false      // config.json есть, но не читается: не пишем поверх, иначе потеряем dirs и ключ
    property bool cfgLoaded: false      // до первого чтения не пишем: IPC set мог прийти раньше и затереть файл
    property var cfgEarly: []           // такие ранние правки ждут и применяются после чтения
    function setCfg(key, value) {
        if (hosted) { host.save(key, value); return; }
        if (!cfgLoaded) { cfgEarly = cfgEarly.concat([[key, value]]); return; }
        if (cfgBroken) return;
        const c = Object.assign({}, fileCfg); c[key] = value; fileCfg = c;
        cfgFile.setText(JSON.stringify(c, null, 2) + "\n");
    }
    function flushEarlyCfg() { const e = cfgEarly; cfgEarly = []; e.forEach(kv => setCfg(kv[0], kv[1])); }
    function setWh(key, value) { const w = Object.assign({}, wh); w[key] = value; setCfg("wh", w); }
    readonly property bool indexing: reindex.running   // при первом открытии список ещё пуст, это не «ничего»
    // запрос, пришедший во время обхода, не теряется: обход повторится, когда закончится текущий
    // в очереди хранится сама команда: экран и папки могли смениться, пока шёл прежний обход
    property var reindexPending: null
    function reindexCmd() { return [indexer, "--quiet"].concat(cacheArgs(), dirArgs(), extraDirArgs()); }
    function reindexNow() {
        const cmd = reindexCmd();
        if (reindex.running) { reindexPending = cmd; return; }
        reindex.command = cmd; reindex.running = true;
    }
    // папки, куда помощник сохранил картинку вместо выбранной (в неё нельзя писать): обходим и их
    property var extraDirs: []
    function addExtraDir(d) { if (d && dirs.indexOf(d) === -1 && extraDirs.indexOf(d) === -1) extraDirs = extraDirs.concat([d]); }
    function extraDirArgs() { let a = []; extraDirs.forEach(d => { a.push("--dir"); a.push(d); }); return a; }

    // ── Переводы: формат DMS, translations/<язык>.json, ключ английский, внутри {контекст: перевод} ──
    // Язык: "language" в config.json или из LC_ALL / LC_MESSAGES / LANG; нет файла, значит английский.
    readonly property var langFiles: ["ru", "de", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt_BR", "tr", "uk", "zh_CN"]
    readonly property string shellDir: decodeURIComponent(Qt.resolvedUrl(".").toString().replace(/^file:\/\//, "").replace(/\/$/, ""))
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
            catch (e) { root.cfgBroken = text().trim() !== ""; if (!root.cfgBroken) root.fileCfg = {}; }
            root.cfgLoaded = true; root.flushEarlyCfg();
        }
        // файла нет: настройки с нуля; другая ошибка чтения: прежние настройки не трогаем и не пишем поверх
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) { root.fileCfg = {}; root.cfgBroken = false; root.cfgLoaded = true; root.flushEarlyCfg(); }
            else root.cfgBroken = true;
        }
    }

    property var favs: ({})           // путь → true; живёт отдельно, чтобы звезда не перестраивала ленту
    property string itemsSig: ""
    property bool indexLoaded: false     // индекс прочитан хотя бы раз (пустой список после фильтра тоже считается)

    readonly property bool tallTarget: !!targetScreen && targetScreen.height > targetScreen.width
    onTallTargetChanged: if (indexLoaded) loadIndex()
    function loadIndex() {
        let vis = [];
        try {
            // вертикальные картинки только на вертикальном экране; записи пропавшей папки (missing) не показываем
            const tall = tallTarget;
            vis = (JSON.parse(indexFile.text()).items || []).filter(e => !e.missing && !!e.portrait === tall);
        } catch (e) {
            vis = [];
        }
        indexLoaded = true;
        const f = {};
        vis.forEach(e => { if (e.favorite) f[e.path] = true; });
        // звёзды, которые ещё пишутся или ещё не дошли до индекса, важнее индекса: он мог быть прочитан
        // до записи. Когда индекс показывает то же значение, ожидание снимается.
        const pend = Object.assign({}, favPending);
        Object.keys(pend).forEach(p => {
            if (!favQueue.some(j => j[0] === p) && !(favProc.running && favProc.path === p) && !!f[p] === pend[p]) delete pend[p];
            else if (pend[p]) f[p] = true; else delete f[p];
        });
        if (Object.keys(pend).length !== Object.keys(favPending).length) favPending = pend;
        favs = f;
        // список заменяем, только если поменялся состав картинок: иначе лента сбросила бы выбор
        const sig = vis.map(e => [e.path, e.key, e.title, e.description, e.style, e.search,
                                   (e.keywords || []).join(","), (e.tags || []).join(",")].join("|")).join("\n");
        if (sig !== itemsSig) { itemsSig = sig; items = vis; }
    }

    // Звёзды пишутся по одной и по порядку: быстрые щелчки отдельными процессами могли закончиться наоборот
    property var favQueue: []
    property var favPending: ({})       // путь → желаемое значение, пока запись не закончилась
    function toggleFavorite(path) {
        const f = Object.assign({}, favs);
        if (f[path]) delete f[path]; else f[path] = true;
        favs = f;
        const pend = Object.assign({}, favPending); pend[path] = !!f[path]; favPending = pend;
        favQueue = favQueue.concat([[path, f[path] ? "on" : "off"]]);
        if (!favProc.running) favNext();
    }
    function favNext() {
        if (!favQueue.length) return;
        const j = favQueue[0]; favQueue = favQueue.slice(1);
        favProc.path = j[0];
        favProc.command = [indexer, "--quiet", "--favorite", j[0], j[1]].concat(cacheArgs(), dirArgs());
        favProc.running = true;
    }
    Process {
        id: favProc
        property string path: ""
        onExited: code => {
            // не записалось: звезду возвращаем как было, индекс перечитываем
            if (code !== 0 && !root.favQueue.some(j => j[0] === path)) {
                const p = Object.assign({}, root.favPending); delete p[path]; root.favPending = p;
                indexFile.reload();
            }
            // записалось: ожидание снимет loadIndex, когда свежий индекс покажет то же значение
            root.favNext();
        }
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
    property bool semIndexAgain: false   // новый индекс пришёл, пока считались векторы: посчитать ещё раз
    Process {
        id: semIndex; command: [root.semantic, "index", "--quiet"]; environment: ({ OBOI_CACHE: root.cacheDir })
        onExited: if (root.semIndexAgain) { root.semIndexAgain = false; running = true; }
    }

    // screenName: монитор, выбранный в начале действия (переход идёт секунду-другую, экран мог смениться)
    function setWallpaper(path, screenName) {
        const scr = screenName || targetName;
        if (hosted) host.setWallpaper(path, scr);
        // сам по себе: при обоях по мониторам DMS принимает только setFor
        else Quickshell.execDetached(["sh", "-c", 'case "$(dms ipc call wallpaper set "$1")" in *Per-monitor*) dms ipc call wallpaper setFor "$2" "$1";; esac',
                                      "sh", path, scr]);
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
        // сначала экран: от него зависят текущие обои и папка, которую обходит индекс
        pickerScreen = screen || Quickshell.screens[0];
        reindexNow();
        if (hosted) current = hostCurrent; else askCurrent(targetName);
    }

    function randomWallpaper(screen) {
        // экран ставим до проверки списка: на вертикальном мониторе список другой
        randomScreen = screen || null;
        try {
            if (items.length === 0) { reindexNow(); return; }
            let pick = items[Math.floor(Math.random() * items.length)];
            if (pick.path === current && items.length > 1) pick = items[(items.indexOf(pick) + 1) % items.length];
            setWallpaper(pick.path);
        } finally {
            randomScreen = null;
        }
    }
    // запрос текущих обоев в самостоятельном запуске: пока идёт прежний, новый ждёт в очереди,
    // а у идущего экран не меняется (иначе ответ для A приняли бы за ответ для B)
    property string currentNext: ""
    function askCurrent(scr) {
        if (currentProc.running) { currentNext = scr; return; }
        currentProc.forScreen = scr; currentProc.running = true;
    }
    function screenByName(name) { return Quickshell.screens.find(s => s.name === name) || null; }

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
        command: root.reindexCmd()
        onExited: {
            indexFile.reload();
            if (root.reindexPending) { command = root.reindexPending; root.reindexPending = null; running = true; return; }
            if (root.semEnabled) { if (semIndex.running) root.semIndexAgain = true; else semIndex.running = true; }
            // смысловой помощник мог упасть, пока индекса ещё не было: перезапуск через semHold,
            // чтобы не рвать привязку running к semHold && semEnabled
            if (root.semHold && root.semEnabled && !sem.running) { root.semHold = false; Qt.callLater(() => root.semHold = !!root.pickerScreen || semIdle.running); }
        }
    }

    Process {
        id: currentProc
        // при обоях по мониторам DMS отвечает на get ошибкой: тогда getFor для экрана ленты
        // ответ помечен экраном, для которого спрашивали: устаревший ответ (лента уже на другом мониторе)
        // отбрасываем; цвет или пусто тоже ответ, шейдер тогда возьмёт рост вместо перехода
        property string forScreen: ""
        onExited: if (root.currentNext) { const s = root.currentNext; root.currentNext = ""; root.askCurrent(s); }
        command: ["sh", "-c", 'r=$(dms ipc call wallpaper get); case "$r" in ERROR*) dms ipc call wallpaper getFor "$1";; *) printf "%s\n" "$r";; esac',
                  "sh", forScreen]
        stdout: StdioCollector {
            onStreamFinished: { if (!root.currentNext && currentProc.forScreen === root.targetName && !this.text.startsWith("ERROR")) root.current = this.text.trim(); }
        }
    }

    IpcHandler {
        // в DMS: dms ipc call skindancer …; сам по себе (qs -c oboi): qs -c oboi ipc call oboi …
        target: root.hosted ? "skindancer" : "oboi"
        function picker(): void { root.openPicker(root.focusedScreen()); }
        // явный монитор: на композиторах, где DMS не знает фокус (labwc, KWin), иначе берётся первый
        function pickerOn(output: string): void { root.openPicker(root.screenByName(output) || root.focusedScreen()); }
        function random(): void { root.randomWallpaper(root.focusedScreen()); }
        function randomOn(output: string): void { root.randomWallpaper(root.screenByName(output) || root.focusedScreen()); }
        function menuAt(x: real, y: real): void { root.openMenu(root.focusedScreen(), x, y); }
        function menuAtOn(output: string, x: real, y: real): void { root.openMenu(root.screenByName(output) || root.focusedScreen(), x, y); }
        function close(): void { root.menuScreen = null; picker.close(); }     // во время перехода не закрываем
        function next(): void { picker.stepBy(1); }
        function prev(): void { picker.stepBy(-1); }
        function apply(): void { if (root.pickerScreen) picker.apply(); }      // при закрытой ленте ставить нечего
        function find(q: string): void { picker.setQuery(q); }
        function favorite(): void { picker.toggleFavorite(); }
        function favorites(): void { picker.favOnly = !picker.favOnly; }
        function hue(n: int): void { picker.hueFilter = n; }
        function transition(kind: string): void { picker.forcedKind = kind; }
        function view(name: string): void { picker.setView(name); }
        function source(name: string): void { if (root.pickerScreen && (name !== "wallhaven" || root.whEnabled)) picker.source = name; }   // в сеть только при открытой ленте
        function save(): void { picker.whSave(); }
        function help(): void { root.helpScreen = root.focusedScreen(); }
        function closeHelp(): void { root.helpScreen = null; }
        function cell(dx: int, dy: int): void { picker.moveCell(dx, dy); }
        function settings(): void { picker.settingsOpen = !picker.settingsOpen; }
        // true/false становятся логическими значениями, текст в [ ] или { } разбирается как JSON (dirs, wh)
        function set(key: string, value: string): void {
            let v = value === "true" ? true : value === "false" ? false : value;
            if (/^\s*[\[{]/.test(value)) { try { v = JSON.parse(value); } catch (e) { return; } }
            root.setCfg(key, v);
        }
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
