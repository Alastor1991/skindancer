// Страница «Обоев» в настройках DMS (Плагины). Остальное (переход, вид, фильтры wallhaven)
// настраивается прямо в ленте, шестерёнкой.
import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "skindancer"

    StringSetting {
        settingKey: "folder"
        label: I18n.trFor("skindancer", "Wallpaper folder")
        description: I18n.trFor("skindancer", "Where your wallpapers live and where images from wallhaven are saved. Empty: the folder of the current wallpaper.")
        placeholder: "~/Pictures/Wallpapers"
    }
    ToggleSetting {
        settingKey: "catcher"
        label: I18n.trFor("skindancer", "Right-click menu on the desktop")
        description: I18n.trFor("skindancer", "Replaces the DMS desktop menu with the Skindancer menu. Without it, open the picker with: dms ipc call skindancer picker")
        defaultValue: false
    }
    StringSetting {
        settingKey: "wallhaven_apikey"
        label: I18n.trFor("skindancer", "wallhaven API key")
        description: I18n.trFor("skindancer", "Optional. Only needed for NSFW results on wallhaven.cc.")
        placeholder: ""
    }
}
