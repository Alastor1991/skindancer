<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, een surrealistische achtergrondkiezer voor DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
<a href="README.de.md">Deutsch</a> ·
<a href="README.es.md">Español</a> ·
<a href="README.fr.md">Français</a> ·
<a href="README.it.md">Italiano</a> ·
<a href="README.pt_BR.md">Português (BR)</a> ·
<b>Nederlands</b> ·
<a href="README.pl.md">Polski</a> ·
<a href="README.uk.md">Українська</a> ·
<a href="README.tr.md">Türkçe</a> ·
<a href="README.ja.md">日本語</a> ·
<a href="README.ko.md">한국어</a> ·
<a href="README.zh_CN.md">简体中文</a>
</p>

# Skindancer

Een achtergrondkiezer voor [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) in de geest van Salvador Dalí: een overlay over het hele scherm met zoeken, favorieten, drie weergaven, shaderovergangen en ingebouwd zoeken op wallhaven.cc. Het is een DMS-plug-in en werkt direct na installatie op niri, Hyprland en de andere compositors die DMS ondersteunt.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Shaderovergangen: grow, melt, ink en iris"></p>

**De achtergrond wisselt niet zomaar, hij verandert van gedaante.** Een kaart groeit uit de strook tot hij het hele scherm vult, het oude plaatje smelt weg in druppels, inkt loopt eroverheen, of een pupil gaat open en toont het volgende beeld. Vijf overgangen (grow, iris, dissolve, melt, ink), willekeurig gekozen of vastgezet in de instellingen, of helemaal uit.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Strookweergave: schuine kaarten die wiebelen als pudding"></p>

**Een strook schuine kaarten die meeveren als pudding.** Blader je er snel doorheen, dan rekken de kaarten uit, schieten ze door en komen ze weer tot rust.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="Zoeken versmalt de strook terwijl je typt"></p>

**Zoeken.** Op bestandsnaam, titel, beschrijving en tags. Titels en tags kunnen in een klein sidecar-bestand naast de afbeelding staan (`.oboi/<naam>.json`), en afbeeldingen die je vanaf wallhaven opslaat krijgen die vanzelf. Optioneel voegt een lokaal SigLIP2-model zoeken op betekenis toe: Engelse woorden als `desert` of `rain` vinden passende afbeeldingen ook zonder tags.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Muurweergave: een raster waarin je van vak naar vak springt"></p>

**Muur.** Je hele bibliotheek in één oogopslag. Met de pijltoetsen spring je van vak naar vak.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Diepteweergave: kaarten die tot in de verte achter elkaar staan"></p>

**Diepte.** De kaarten verdwijnen de diepte in, als een stapel ansichtkaarten.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: zoeken, filteren, opslaan en dan instellen"></p>

**wallhaven ingebouwd.** Zoek op wallhaven.cc zonder de kiezer te verlaten, met filters voor resolutie, beeldverhouding, sortering, categorieën en contentniveau (purity). Met Enter sla je de afbeelding samen met de tags op in je achtergrondmap, en dan verschijnt ze in je bibliotheek.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Instellingen: keuzelijsten die uitrollen als een zacht laken met druppels"></p>

**Instellingen in de kiezer zelf.** Elke optie is een keuzelijst die uitrolt als een zacht laken en aan de rand druppelt. De interface is beschikbaar in 14 talen en volgt de taal van DMS.

## Installatie

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Zet daarna **Skindancer** aan in DMS Settings → Plugins. (Heb je `XDG_CONFIG_HOME` ingesteld, dan is de map `$XDG_CONFIG_HOME/dms/plugins`.)

Voor het indexeren, de miniaturen en wallhaven heeft de kiezer een paar kleine hulpprogramma's nodig. Die kun je op twee manieren regelen:

- **Kant-en-klare binary, verder hoef je niets te installeren.** Download `oboi-helper` uit de [nieuwste release](https://github.com/Alastor1991/skindancer/releases/latest) naar de map `bin` van de plug-in en maak het bestand uitvoerbaar:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Python, Pillow, numpy, onnxruntime en tokenizers zitten erin, en hij draait op elk x86_64-Linuxsysteem met glibc 2.28 of nieuwer. In de release staat ook `oboi-helper.sha256`. Je kunt hem ook zelf bouwen met `tools/build-helper.sh` (daarvoor heb je podman of docker nodig).
- **Systeem-Python.** `python3` en Pillow (`python-pillow` op Arch, `python3-pil` op Debian en Ubuntu, `python3-pillow` op Fedora, `python313-Pillow` op openSUSE). Voor zoeken op betekenis ook onnxruntime, tokenizers en numpy.

Zoeken op betekenis is optioneel en heeft de modelbestanden nodig (ongeveer 410 MB): voer `tools/get-model.sh` uit. Zonder die bestanden zoekt de kiezer op woorden.

### NixOS

De plug-in heeft DMS 2.1.2 of nieuwer nodig. nixpkgs 26.05 levert DMS 1.4.6, dus neem het DMS-pakket uit de flake van DMS zelf en voeg Skindancer toe als declaratieve plug-in:

```nix
# flake inputs
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
      hash = "";   # bij de eerste build toont nix de juiste hash
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Zet daarna de plug-in aan in DMS Settings → Plugins. De kant-en-klare `oboi-helper` draait op NixOS niet zonder `programs.nix-ld.enable = true`. Zonder die optie gebruikt Skindancer de Python hierboven, en dat is op NixOS de gebruikelijke manier. Voor zoeken op betekenis voeg je `ps.onnxruntime ps.tokenizers ps.numpy` toe aan de Python-pakketten. Een gewone `git clone` naar `~/.config/dms/plugins` werkt op NixOS ook.

## Gebruik

- **De kiezer openen:** `dms ipc call skindancer picker`. Koppel dit aan een toets in je compositor, in niri bijvoorbeeld zo: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Of zet **Rechtsklikmenu op het bureaublad** aan in de plug-ininstellingen: dan vervangt het menu van Skindancer het DMS-bureaubladmenu, en als je het weer uitzet komt het DMS-menu terug. Op labwc, Sway, Scroll en KWin houdt de compositor de klikken op het bureaublad voor zichzelf. Daar blijft het menu dus (net als bij DMS) uit en gebruik je een toets.
- **Toetsen:** ← → bladeren, ↑ ↓ per rij in de rasters, Enter stelt de achtergrond in, Ctrl+D voegt toe aan favorieten, Ctrl+1 2 3 wisselen van weergave, Ctrl+4 opent wallhaven, F1 help, Esc sluit. Het tandwiel opent de instellingen.
- **Andere IPC-commando's:** `random`, `next`, `prev`, `apply`, `find <woorden>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <naam>`, `help`, `close`.

De kiezer opent op de monitor die de focus heeft en werkt met achtergronden per monitor. Op labwc en KWin kan DMS niet zien welke monitor de focus heeft, dus geef je de monitor zelf op: `dms ipc call skindancer pickerOn DP-1` (dat kan ook met `randomOn <output>` en `menuAtOn <output> <x> <y>`).

## Instellingen

Op de plug-inpagina in de DMS-instellingen vind je de achtergrondmap (leeg betekent de map van de huidige achtergrond, of je map Afbeeldingen), het rechtsklikmenu en de wallhaven-API-sleutel. Al het andere stel je in de kiezer zelf in: overgang, startweergave, veerkracht, bijschriften, toetsaanwijzingen, zoeken op betekenis en het wallhaven-tabblad met zijn filters.

## Wat het wegschrijft en wanneer het online gaat

- `~/.cache/oboi/dms/`: de index en de miniaturen. Ze worden opnieuw aangemaakt als je ze verwijdert.
- `~/.cache/oboi/helper-<hash>/`: de kant-en-klare helper pakt zichzelf bij de eerste start hier uit (ongeveer 180 MB). Oude versies worden een dag na een update verwijderd.
- `~/.local/share/oboi/models/siglip2/`: het optionele model voor zoeken op betekenis, alleen als je het downloadt.
- `<achtergrondmap>/.oboi/<bestand>.json`: favorieten en, bij afbeeldingen die van wallhaven zijn opgeslagen, hun tags en bron. Deze kleine bestanden gaan mee met de map als je die synchroniseert. Is de map alleen-lezen, dan komen de favorieten in plaats daarvan in `~/.local/state/oboi/favorites.json` en gaan afbeeldingen die je van wallhaven opslaat naar `<Afbeeldingen>/Wallpapers`.
- Netwerk: alleen het wallhaven-tabblad maakt verbinding met wallhaven.cc, en alleen zolang het openstaat. Standaard SFW en 4K. Voor NSFW heb je je eigen wallhaven-API-sleutel nodig. De sleutel gaat mee in een request-header en nooit in het adres.

## Getest op

Geïnstalleerd zoals deze README beschrijft, op schone virtuele machines met DMS 2.1.2 volgens de officiële instructies: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 en openSUSE Tumbleweed met niri, Arch Linux met Hyprland, Sway en labwc (live bediend met toetsenbord en muis), en NixOS 26.05, waar de plug-in declaratief uit de Nix-store is geïnstalleerd. Elk systeem is getest met systeem-Python en met de kant-en-klare binary (op NixOS valt de binary netjes terug op Python, zoals bedoeld). Dagelijks draait het op CachyOS met niri. De testscripts staan in `tools/vm/`.

Nog niet getest: echte NVIDIA- en AMD-videokaarten (de virtuele machines tekenen met virgl, dus hoe soepel de overgangen lopen was daar niet te beoordelen), meerdere fysieke monitoren, Gentoo en Void.

## Bekende beperkingen

- Het veld voor de API-sleutel in de DMS-instellingen toont de sleutel in leesbare tekst: DMS-plug-ininstellingen kennen nog geen verborgen invoerveld.
- Verwijder je de plug-in terwijl het rechtsklikmenu aanstaat, zet dan het DMS-bureaubladmenu weer aan in de DMS-instellingen (Desktop Widgets → General → Right-click menu).
- Zonder GPU (softwarematige rendering van Qt) zijn de kaarten gewone rechthoeken en wisselen achtergronden zonder overgang.
- Staande afbeeldingen verschijnen alleen op een monitor in portretstand.

## De naam

Face Dancers zijn de gedaanteverwisselaars uit *Dune* van Frank Herbert: ze nemen elk gezicht aan. Dat is precies wat dit programma met je bureaublad doet. In het Russisch heet het project «Лицедейка» (litsedeyka, "de gezichtsdanseres" of "de toneelspeelster"). De werknaam was Oboi (обои, Russisch voor "behang" of "achtergrond"), en die zie je nog steeds terug in bestands- en cachenamen.

## Over dit project

Ik ben Alex. Ik wil eerlijk zijn over hoe Skindancer is gemaakt: ik heb de code niet zelf geschreven. Alle code is geschreven door Claude, de AI van Anthropic, in Claude Code. Mijn bijdrage was dat ik wist wat ik wilde: een mooie achtergrondkiezer die direct werkt op DMS en die ik met anderen kan delen. Ik beschreef het, bekeek elke versie, zei heel vaak "nee, niet zo", besliste wat erin bleef en wat eruit ging, en testte het op mijn eigen machines.

Mijn Engels is niet goed. Ik lees issues en beantwoord ze via een vertaalprogramma, dus schrijf alsjeblieft eenvoudig en vergeef me als mijn antwoorden vreemd klinken. Issues en pull requests in elke taal zijn welkom.

## Licentie

GPL-3.0-or-later, zie [LICENSE](LICENSE). De iconen en shaders zijn voor dit project gemaakt. De afbeeldingen in de preview zijn van hun makers en maken geen deel uit van het project.
