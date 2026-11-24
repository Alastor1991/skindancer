// «Обои» плагином DMS: демон живёт, пока плагин включён, и держит ядро Oboi.qml.
// Обои ставятся через SessionData, настройки хранит DMS (plugin_settings.json), переводы берёт I18n.
// Ленту открывает `dms ipc call oboi picker` или правый клик по столу, если это включено в настройках.
import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string pid: "skindancer"
    readonly property var keys: ["transition", "semantic", "jelly", "hints", "captions", "wallhaven", "view", "wh",
                                 "wallhaven_apikey", "catcher"]
    property var cfg: ({})

    function readCfg() {
        if (!pluginService) return;
        const c = {};
        keys.forEach(k => {
            const v = pluginService.loadPluginData(pid, k, null);
            if (v !== null && v !== undefined && v !== "") c[k] = v;
        });
        const folder = pluginService.loadPluginData(pid, "folder", "");
        if (folder) c.dirs = [folder];
        cfg = c;
    }
    Connections {
        target: root.pluginService
        function onPluginDataChanged(id) { if (id === root.pid) root.readCfg(); }
    }

    // Своего пункта в меню стола DMS не даёт. Если включён правый клик «Обоев», меню DMS выключаем,
    // чтобы два слоя не спорили за клик, и возвращаем прежнее значение, когда его выключают.
    // На labwc, Sway, Scroll и KWin клики по столу заняты самим композитором (меню labwc, привязки
    // --whole-window); DMS там тоже не ловит правый клик, и «Обои» следуют ей: открытие по клавише.
    readonly property bool catcher: cfg.catcher === true && !CompositorService.reservesDesktopInput
    onCatcherChanged: syncMenu()
    function syncMenu() {
        if (!pluginService) return;
        if (catcher && SettingsData.desktopContextMenu !== "off") {
            pluginService.savePluginData(pid, "dmsMenuBefore", SettingsData.desktopContextMenu);
            SettingsData.set("desktopContextMenu", "off");
        } else if (!catcher) {
            restoreMenu();
        }
    }
    function restoreMenu() {
        const before = pluginService ? pluginService.loadPluginData(pid, "dmsMenuBefore", "") : "";
        if (before && SettingsData.desktopContextMenu === "off") {
            SettingsData.set("desktopContextMenu", before);
            pluginService.savePluginData(pid, "dmsMenuBefore", "");
        }
    }

    Component.onCompleted: { readCfg(); syncMenu(); }
    Component.onDestruction: if (catcher) restoreMenu()

    Oboi {
        id: oboi
        hosted: true
        hostCfg: Object.assign({}, root.cfg, { catcher: root.catcher })
        // текущие обои того экрана, где открыта лента (при обоях по мониторам у каждого свои)
        hostCurrent: SessionData.perMonitorWallpaper && oboi.targetName
                     ? SessionData.getMonitorWallpaper(oboi.targetName) : SessionData.wallpaperPath
        host: ({
            setWallpaper: (path, screenName) => {
                // так же, как меню стола самой DMS: ручной выбор выключает смену обоев по папке
                if (SessionData.perMonitorWallpaper && screenName) {
                    SessionData.setMonitorWallpaper(screenName, path);
                    SessionData.setMonitorCyclingFolderPath(screenName, "");
                } else {
                    SessionData.setWallpaper(path);
                    SessionData.wallpaperCyclingFolderPath = "";      // как `dms ipc call wallpaper set`
                    SessionData.saveSettings();
                }
            },
            save: (key, value) => root.pluginService.savePluginData(root.pid, key, value),
            focusedScreen: () => CompositorService.getFocusedScreenName(),
            tr: (text, ctx) => I18n.trFor("skindancer", text, ctx === text ? undefined : ctx)
        })
    }
}
