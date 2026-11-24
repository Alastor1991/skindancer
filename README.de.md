<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, ein surrealer Wallpaper-Picker für DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
<b>Deutsch</b> ·
<a href="README.es.md">Español</a> ·
<a href="README.fr.md">Français</a> ·
<a href="README.it.md">Italiano</a> ·
<a href="README.pt_BR.md">Português (BR)</a> ·
<a href="README.nl.md">Nederlands</a> ·
<a href="README.pl.md">Polski</a> ·
<a href="README.uk.md">Українська</a> ·
<a href="README.tr.md">Türkçe</a> ·
<a href="README.ja.md">日本語</a> ·
<a href="README.ko.md">한국어</a> ·
<a href="README.zh_CN.md">简体中文</a>
</p>

# Skindancer

Ein Wallpaper-Picker für [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) im Geiste Salvador Dalís: ein Vollbild-Overlay mit Suche, Favoriten, drei Ansichten, Shader-Übergängen und eingebauter Suche auf wallhaven.cc. Skindancer ist ein DMS-Plugin und läuft ohne weitere Einrichtung unter niri, Hyprland und den anderen Compositoren, die DMS unterstützt.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Shader-Übergänge: Wachsen, Schmelzen, Tinte und Iris"></p>

**Das Wallpaper wechselt nicht einfach, es verwandelt sich.** Eine Karte wächst aus dem Streifen und füllt den ganzen Bildschirm, das alte Bild zerschmilzt in Tropfen, Tinte läuft darüber, oder eine Pupille öffnet sich und gibt den Blick auf das nächste frei. Es gibt fünf Übergänge (Wachsen, Iris, Auflösen, Schmelzen, Tinte). Sie werden zufällig gewählt oder in den Einstellungen festgelegt, oder du schaltest sie ganz ab.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Streifenansicht: schräge Karten, die wie Wackelpudding federn"></p>

**Ein Streifen aus schrägen Karten mit Wackelpudding-Effekt.** Blätterst du schnell durch, dehnen sich die Karten, schießen übers Ziel hinaus und pendeln sich ein.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="Die Suche grenzt den Streifen schon beim Tippen ein"></p>

**Suche.** Nach Dateiname, Titel, Beschreibung und Tags. Titel und Tags können in einer kleinen Begleitdatei neben dem Bild liegen (`.oboi/<Name>.json`); für Bilder, die du von wallhaven speicherst, wird sie automatisch angelegt. Mit einem lokalen SigLIP2-Modell kommt optional eine Suche nach Bedeutung dazu: Englische Wörter wie `desert` oder `rain` finden passende Bilder auch ohne Tags.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Wand-Ansicht: ein Raster, in dem man von Feld zu Feld springt"></p>

**Wand.** Die ganze Bibliothek auf einen Blick; mit den Pfeiltasten springst du von Feld zu Feld.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Tiefen-Ansicht: Karten, die sich in die Ferne staffeln"></p>

**Tiefe.** Die Karten weichen wie ein Stapel Postkarten in die Szene zurück.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: suchen, filtern, speichern, dann anwenden"></p>

**wallhaven eingebaut.** Durchsuche wallhaven.cc direkt im Picker, mit Filtern für Auflösung, Seitenverhältnis, Sortierung, Kategorien und Jugendfreigabe. Mit Enter wird das Bild samt Tags in deinem Wallpaper-Ordner gespeichert und taucht in deiner Bibliothek auf.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Einstellungen: Dropdown-Listen, die sich wie ein weiches Tuch mit Tropfen entrollen"></p>

**Einstellungen direkt im Picker.** Jede Option ist eine Dropdown-Liste, die sich wie ein weiches Tuch entrollt und am Rand tropft. Die Oberfläche spricht 14 Sprachen und folgt der Sprache von DMS.

## Installation

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Aktiviere danach **Skindancer** in den DMS-Einstellungen unter Plugins. (Hast du `XDG_CONFIG_HOME` gesetzt, liegt der Ordner unter `$XDG_CONFIG_HOME/dms/plugins`.)

Für Indizierung, Vorschaubilder und wallhaven braucht der Picker kleine Hilfsprogramme. Du hast zwei Möglichkeiten, sie bereitzustellen:

- **Fertige Binärdatei, sonst muss nichts installiert werden.** Lade `oboi-helper` aus dem [neuesten Release](https://github.com/Alastor1991/skindancer/releases/latest) in den Ordner `bin` des Plugins herunter und mach die Datei ausführbar:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Die Datei bringt Python, Pillow, numpy, onnxruntime und tokenizers mit und läuft auf jedem x86_64-Linux mit glibc 2.28 oder neuer. Im Release liegt auch `oboi-helper.sha256`. Du kannst sie selbst mit `tools/build-helper.sh` bauen (dafür brauchst du podman oder docker).
- **System-Python.** `python3` und Pillow (`python-pillow` unter Arch, `python3-pil` unter Debian und Ubuntu, `python3-pillow` unter Fedora, `python313-Pillow` unter openSUSE). Für die Suche nach Bedeutung außerdem onnxruntime, tokenizers und numpy.

Die Suche nach Bedeutung ist optional und braucht die Modelldateien (rund 410 MB): Führe dazu `tools/get-model.sh` aus. Ohne sie sucht der Picker nach Wörtern.

### NixOS

Das Plugin braucht DMS 2.1.2 oder neuer. nixpkgs 26.05 enthält nur DMS 1.4.6. Nimm das DMS-Paket deshalb aus dem Flake von DMS und füge Skindancer als deklaratives Plugin hinzu:

```nix
# Flake-Inputs
dms = { url = "github:duxlabs-dev/dux-shell/stable"; inputs.nixpkgs.follows = "nixpkgs"; };
```

```nix
programs.dms-shell = {
  enable = true;
  systemd.enable = true;
  package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
  plugins.skindancer = {
    enable = true;
    src = pkgs.fetchFromGitHub {
      owner = "Alastor1991"; repo = "skindancer"; rev = "v0.1.1";
      hash = "";   # beim ersten Build zeigt nix den richtigen Hash an
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Schalte das Plugin danach in den DMS-Einstellungen unter Plugins ein. Die fertige Binärdatei `oboi-helper` läuft unter NixOS nicht ohne `programs.nix-ld.enable = true`; ohne diese Option nutzt Skindancer das oben genannte Python, und das ist unter NixOS der normale Weg. Für die Suche nach Bedeutung fügst du `ps.onnxruntime ps.tokenizers ps.numpy` zu den Python-Paketen hinzu. Ein einfaches `git clone` nach `~/.config/dms/plugins` funktioniert unter NixOS ebenfalls.

## Benutzung

- **Picker öffnen:** `dms ipc call skindancer picker`. Leg den Befehl auf eine Taste in deinem Compositor, in niri zum Beispiel so: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Oder schalte in den Plugin-Einstellungen **Rechtsklick-Menü auf dem Desktop** ein: Das ersetzt das DMS-Desktopmenü durch das von Skindancer, und beim Ausschalten kommt das DMS-Menü zurück. Unter labwc, Sway, Scroll und KWin behält der Compositor die Klicks auf den Desktop für sich. Dort bleibt das Menü (wie bei DMS) deshalb aus, und du öffnest den Picker per Tastenkürzel.
- **Tasten:** ← → blättern, ↑ ↓ zeilenweise in den Rasteransichten, Enter setzt das Wallpaper, Ctrl+D fügt zu den Favoriten hinzu, Ctrl+1 2 3 wechseln die Ansicht, Ctrl+4 öffnet wallhaven, F1 Hilfe, Esc schließt. Das Zahnrad öffnet die Einstellungen.
- **Weitere IPC-Befehle:** `random`, `next`, `prev`, `apply`, `find <Wörter>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <Name>`, `help`, `close`.

Der Picker öffnet sich auf dem Monitor mit dem Fokus und kommt mit Wallpapern pro Monitor zurecht. Unter labwc und KWin kann DMS nicht erkennen, welcher Monitor den Fokus hat. Gib ihn dort deshalb selbst an: `dms ipc call skindancer pickerOn DP-1` (ebenso `randomOn <output>` und `menuAtOn <output> <x> <y>`).

## Einstellungen

Auf der Plugin-Seite in den DMS-Einstellungen stellst du den Wallpaper-Ordner ein (leer heißt: der Ordner des aktuellen Wallpapers oder dein Bilder-Ordner), das Rechtsklick-Menü und den wallhaven-API-Schlüssel. Alles andere stellst du im Picker selbst ein: Übergang, Startansicht, Elastizität, Beschriftungen, Tastenhinweise, Suche nach Bedeutung und den wallhaven-Tab mit seinen Filtern.

## Was geschrieben wird und wann es online geht

- `~/.cache/oboi/dms/`: der Index und die Vorschaubilder. Beides wird neu angelegt, wenn du den Ordner löschst.
- `~/.cache/oboi/helper-<hash>/`: Die fertige Binärdatei entpackt sich beim ersten Start hierhin (rund 180 MB). Alte Versionen werden einen Tag nach einem Update entfernt.
- `~/.local/share/oboi/models/siglip2/`: das optionale Modell für die Suche nach Bedeutung, nur wenn du es herunterlädst.
- `<Wallpaper-Ordner>/.oboi/<Datei>.json`: Favoriten und, bei von wallhaven gespeicherten Bildern, deren Tags und Quelle. Diese kleinen Dateien wandern mit dem Ordner mit, wenn du ihn synchronisierst. Ist der Ordner schreibgeschützt, landen die Favoriten stattdessen in `~/.local/state/oboi/favorites.json`, und von wallhaven gespeicherte Bilder in `<Bilder>/Wallpapers`.
- Netzwerk: Nur der wallhaven-Tab spricht mit wallhaven.cc, und nur solange er geöffnet ist. Standardmäßig SFW und 4K. Für NSFW brauchst du einen eigenen wallhaven-API-Schlüssel; er wird im Header der Anfrage übertragen, nie in der Adresse.

## Getestet auf

So installiert, wie es diese README beschreibt, auf frischen virtuellen Maschinen mit DMS 2.1.2, eingerichtet nach der offiziellen Anleitung: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 und openSUSE Tumbleweed mit niri, Arch Linux mit Hyprland, Sway und labwc (live mit Tastatur und Maus bedient) sowie NixOS 26.05, wo das Plugin deklarativ aus dem Nix-Store installiert wurde. Jedes System wurde mit System-Python und mit der fertigen Binärdatei geprüft (unter NixOS fällt die Binärdatei korrekt auf Python zurück). Im Alltag läuft es auf CachyOS mit niri. Die Testskripte liegen in `tools/vm/`.

Noch nicht getestet: echte NVIDIA- und AMD-Grafikkarten (die virtuellen Maschinen zeichnen mit virgl, daher ließ sich dort nicht beurteilen, wie flüssig die Übergänge laufen), mehrere physische Monitore, Gentoo und Void.

## Bekannte Einschränkungen

- Das Feld für den API-Schlüssel in den DMS-Einstellungen zeigt den Schlüssel im Klartext: Die Plugin-Einstellungen von DMS haben noch kein verdecktes Eingabefeld.
- Entfernst du das Plugin, während sein Rechtsklick-Menü eingeschaltet ist, schalte das DMS-Desktopmenü in den DMS-Einstellungen wieder ein (Desktop Widgets → General → Right-click menu).
- Ohne GPU (Qt-Softwarerendering) sind die Karten schlichte Rechtecke, und Wallpaper wechseln ohne Übergang.
- Hochformat-Bilder erscheinen nur auf einem Monitor im Hochformat.

## Der Name

Die Gesichtstänzer (Face Dancers) sind die Gestaltwandler aus Frank Herberts *Dune*: Sie können jedes beliebige Gesicht annehmen. Genau das macht dieses Programm mit deinem Desktop. Auf Russisch heißt das Projekt «Лицедейка» (Litsedejka, „die Gesichtstänzerin“ oder „die Schauspielerin“). Der Arbeitsname war Oboi (обои, russisch für „Tapete“ und „Wallpaper“); er steckt bis heute in Datei- und Cache-Namen.

## Über dieses Projekt

Ich bin Alex. Ich möchte ehrlich sagen, wie Skindancer entstanden ist: Ich habe den Code nicht geschrieben. Geschrieben hat ihn komplett Claude, die KI von Anthropic, in Claude Code. Mein Beitrag war, zu wissen, was ich will: einen schönen Wallpaper-Picker, der unter DMS ohne weitere Einrichtung läuft und den ich mit anderen teilen kann. Ich habe ihn beschrieben, mir jede Version angesehen, oft „nein, so nicht“ gesagt, entschieden, was bleibt und was wegfällt, und alles auf meinen eigenen Rechnern getestet.

Mein Englisch ist nicht gut. Ich lese Issues und beantworte sie mithilfe eines Übersetzers. Schreibt deshalb bitte einfach, und seht mir nach, wenn meine Antworten seltsam klingen. Issues und Pull Requests sind in jeder Sprache willkommen.

## Lizenz

GPL-3.0-or-later, siehe [LICENSE](LICENSE). Die Icons und Shader wurden eigens für dieses Projekt erstellt. Die Bilder in der Vorschau gehören ihren Urhebern und sind nicht Teil des Projekts.
