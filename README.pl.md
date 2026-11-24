<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, surrealistyczny selektor tapet dla DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
<a href="README.de.md">Deutsch</a> ·
<a href="README.es.md">Español</a> ·
<a href="README.fr.md">Français</a> ·
<a href="README.it.md">Italiano</a> ·
<a href="README.pt_BR.md">Português (BR)</a> ·
<a href="README.nl.md">Nederlands</a> ·
<b>Polski</b> ·
<a href="README.uk.md">Українська</a> ·
<a href="README.tr.md">Türkçe</a> ·
<a href="README.ja.md">日本語</a> ·
<a href="README.ko.md">한국어</a> ·
<a href="README.zh_CN.md">简体中文</a>
</p>

<p align="center">
<a href="https://github.com/Alastor1991/skindancer/releases/latest"><img src="https://img.shields.io/github/v/release/Alastor1991/skindancer?label=release" alt="release"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0--or--later-blue" alt="GPL-3.0-or-later"></a>
<a href="https://github.com/duxlabs-dev/dux-shell"><img src="https://img.shields.io/badge/DMS-2.1.2%2B-8a6cd6" alt="DMS 2.1.2+"></a>
<a href="docs/README.md"><img src="https://img.shields.io/badge/docs-English-informational" alt="technical docs (English)"></a>
</p>

# Skindancer

Selektor tapet dla [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) w duchu Salvadora Dalego: pełnoekranowa nakładka z wyszukiwaniem, ulubionymi, trzema widokami, przejściami opartymi na shaderach i wbudowanym wyszukiwaniem w wallhaven.cc. To wtyczka do DMS, która działa od razu na niri, Hyprland i innych kompozytorach obsługiwanych przez DMS.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Przejścia na shaderach: powiększenie, topnienie, atrament i tęczówka"></p>

**Tapeta nie tylko się zmienia, ale wręcz przeobraża.** Karta wyrasta ze wstęgi i wypełnia cały ekran, stary obraz spływa kroplami, rozlewa się po nim atrament albo otwiera się źrenica, za którą widać już następny. Przejść jest pięć (powiększenie, tęczówka, rozpuszczanie, topnienie, atrament). Skindancer losuje je sam, możesz też przypiąć jedno w ustawieniach albo wyłączyć je całkiem.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Widok wstęgi: pochylone karty, które trzęsą się jak galaretka"></p>

**Wstęga pochylonych kart, które sprężynują jak galaretka.** Przewijasz, a karty się rozciągają, przelatują odrobinę za daleko i wracają na miejsce.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="Wyszukiwanie zawęża wstęgę w trakcie pisania"></p>

**Wyszukiwanie** po nazwie pliku, tytule, opisie i tagach. Tytuły i tagi można trzymać w małym pliku obok obrazka (`.oboi/<nazwa>.json`), a obrazki zapisane z wallhaven dostają go automatycznie. Opcjonalnie lokalny model SigLIP2 dodaje wyszukiwanie po znaczeniu: angielskie słowa, takie jak `desert` albo `rain`, znajdą pasujące obrazy nawet bez tagów.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Widok ściany: siatka, po której skaczesz z pola na pole"></p>

**Ściana.** Cała biblioteka na jednym ekranie, a strzałkami przeskakujesz z komórki na komórkę.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Widok głębi: karty ułożone jedna za drugą w głąb"></p>

**Głębia.** Karty oddalają się w głąb sceny jak stos pocztówek.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: szukaj, filtruj, zapisz, potem ustaw"></p>

**Wbudowany wallhaven.** Szukasz na wallhaven.cc prosto z selektora, z filtrami rozdzielczości, proporcji, sortowania, kategorii oraz rodzaju treści (purity). Enter zapisuje obraz razem z tagami w folderze z tapetami, a obraz pojawia się w twojej bibliotece.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Ustawienia: listy rozwijane, które rozpościerają się jak miękka płachta i kapią z brzegu"></p>

**Ustawienia w samym selektorze.** Każda opcja to lista rozwijana, która rozpościera się jak miękka płachta i kapie z brzegu. Interfejs jest dostępny w 14 językach i używa tego samego języka co DMS.

## Instalacja

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Potem włącz wtyczkę **Skindancer** w ustawieniach DMS, w sekcji Plugins. (Jeśli masz ustawioną zmienną `XDG_CONFIG_HOME`, folder to `$XDG_CONFIG_HOME/dms/plugins`.)

Selektor potrzebuje małych programów pomocniczych do indeksowania, miniatur i wallhaven. Możesz je zdobyć na dwa sposoby:

- **Gotowy plik binarny, nic więcej nie trzeba instalować.** Pobierz `oboi-helper` z [najnowszego wydania](https://github.com/Alastor1991/skindancer/releases/latest) do folderu `bin` wtyczki i nadaj mu uprawnienia do wykonywania:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Ma w sobie Pythona, Pillow, numpy, onnxruntime oraz tokenizers i działa na każdym Linuksie x86_64 z glibc 2.28 lub nowszym. W wydaniu jest też plik `oboi-helper.sha256`. Ten plik możesz zbudować samodzielnie skryptem `tools/build-helper.sh` (potrzebny podman albo docker).
- **Systemowy Python.** `python3` i Pillow (`python-pillow` w Archu, `python3-pil` w Debianie i Ubuntu, `python3-pillow` w Fedorze, `python313-Pillow` w openSUSE). Do wyszukiwania po znaczeniu potrzebne są jeszcze onnxruntime, tokenizers i numpy.

Wyszukiwanie po znaczeniu jest opcjonalne i wymaga plików modelu (około 410 MB): uruchom `tools/get-model.sh`. Bez nich selektor szuka po słowach.

### NixOS

Wtyczka wymaga DMS 2.1.2 lub nowszego. W nixpkgs 26.05 jest DMS 1.4.6, więc pakiet DMS weź z jego flake'a i dodaj Skindancera jako wtyczkę deklaratywną:

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
      owner = "Alastor1991"; repo = "skindancer"; rev = "v0.1.2";
      hash = "";   # nix wypisze właściwy hash przy pierwszym budowaniu
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Potem włącz wtyczkę w ustawieniach DMS, w sekcji Plugins. Gotowy `oboi-helper` nie uruchomi się na NixOS bez `programs.nix-ld.enable = true`. Bez tej opcji Skindancer korzysta z Pythona z konfiguracji powyżej i na NixOS jest to zwykła droga. Do wyszukiwania po znaczeniu dodaj do pakietów Pythona `ps.onnxruntime ps.tokenizers ps.numpy`. Zwykłe `git clone` do `~/.config/dms/plugins` na NixOS też działa.

## Użycie

- **Otwarcie selektora:** `dms ipc call skindancer picker`. Przypisz to polecenie do skrótu klawiszowego w kompozytorze, na przykład w niri: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Możesz też włączyć w ustawieniach wtyczki opcję **Menu prawego przycisku myszy na pulpicie**: wtedy menu Skindancera zastępuje menu pulpitu DMS, a po wyłączeniu tej opcji menu DMS wraca. W labwc, Sway, Scroll i KWin kliknięcia w pulpit przechwytuje sam kompozytor, więc tam (tak samo jak w DMS) menu zostaje wyłączone i otwierasz selektor skrótem klawiszowym.
- **Klawisze:** ← → przeglądanie, ↑ ↓ przejście o rząd w siatkach, Enter ustawia tapetę, Ctrl+D dodaje do ulubionych, Ctrl+1 2 3 przełączają widoki, Ctrl+4 otwiera wallhaven, F1 pomoc, Esc zamyka. Zębatka otwiera ustawienia.
- **Pozostałe polecenia IPC:** `random`, `next`, `prev`, `apply`, `find <words>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <name>`, `help`, `close`.

Selektor otwiera się na aktywnym monitorze (tym, który ma fokus) i obsługuje osobne tapety na każdym monitorze. W labwc i KWin powłoka DMS nie potrafi ustalić, który monitor ma fokus, więc wskaż go sam: `dms ipc call skindancer pickerOn DP-1` (są też `randomOn <output>` i `menuAtOn <output> <x> <y>`).

## Ustawienia

Na stronie wtyczki w ustawieniach DMS znajdziesz folder z tapetami (puste pole oznacza folder bieżącej tapety albo twój folder Obrazy), menu prawego przycisku myszy i klucz API wallhaven. Wszystko inne ustawiasz w samym selektorze: przejście, widok startowy, sprężystość, podpisy, podpowiedzi klawiszy, wyszukiwanie po znaczeniu oraz kartę wallhaven z jej filtrami.

## Co zapisuje i kiedy łączy się z internetem

- `~/.cache/oboi/dms/`: indeks i miniatury. Po usunięciu zostaną utworzone od nowa.
- `~/.cache/oboi/helper-<hash>/`: gotowy program pomocniczy rozpakowuje się tutaj przy pierwszym uruchomieniu (około 180 MB). Stare wersje są usuwane dzień po aktualizacji.
- `~/.local/share/oboi/models/siglip2/`: opcjonalny model do wyszukiwania po znaczeniu, tylko jeśli go pobierzesz.
- `<folder z tapetami>/.oboi/<plik>.json`: ulubione, a dla obrazków zapisanych z wallhaven także ich tagi i źródło. Te małe pliki przenoszą się razem z folderem, jeśli go synchronizujesz. Jeśli folder jest tylko do odczytu, ulubione trafiają zamiast tego do `~/.local/state/oboi/favorites.json`, a obrazki zapisane z wallhaven do `<Obrazy>/Wallpapers`.
- Sieć: z wallhaven.cc łączy się tylko karta wallhaven i tylko wtedy, gdy jest otwarta. Domyślnie SFW i 4K. NSFW wymaga własnego klucza API wallhaven, a klucz jest wysyłany w nagłówku żądania, nigdy w adresie.

## Na czym testowano

Skindancer był instalowany dokładnie według tego README na czystych maszynach wirtualnych z DMS 2.1.2 skonfigurowanym zgodnie z oficjalną instrukcją: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 i openSUSE Tumbleweed na niri, Arch Linux na Hyprlandzie, Sway i labwc (tu sterowałem maszynami na żywo klawiaturą i myszą) oraz NixOS 26.05 z wtyczką zainstalowaną deklaratywnie z Nix store. Każdą maszynę sprawdzono zarówno z systemowym Pythonem, jak i z gotowym plikiem binarnym (na NixOS plik binarny zgodnie z oczekiwaniami przełącza się na Pythona). Na co dzień używam go na CachyOS z niri. Skrypty testowe są w `tools/vm/`.

Jeszcze nie przetestowano: prawdziwych kart NVIDIA i AMD (maszyny wirtualne rysują przez virgl, więc płynności przejść nie dało się tam ocenić), kilku fizycznych monitorów, Gentoo i Void.

## Znane ograniczenia

- Pole klucza API w ustawieniach DMS pokazuje klucz jawnym tekstem: ustawienia wtyczek DMS nie mają jeszcze pola, które ukrywa wpisywane znaki.
- Jeśli usuniesz wtyczkę, gdy jej menu prawego przycisku myszy jest włączone, włącz z powrotem menu pulpitu DMS w ustawieniach DMS (Desktop Widgets → General → Right-click menu).
- Bez GPU (renderowanie programowe Qt) karty są zwykłymi prostokątami, a tapety zmieniają się bez przejścia.
- Pionowe obrazy pojawiają się tylko na monitorze ustawionym pionowo.

## Nazwa

Tancerze Oblicza (ang. Face Dancers) to zmiennokształtni z *Diuny* Franka Herberta: potrafią przybrać dowolną twarz. To samo robi ten program z twoim pulpitem. Po rosyjsku projekt nazywa się «Лицедейка» (litsedeyka, czyli „tancerka oblicza” albo „aktorka”). Roboczą nazwą było Oboi (обои, po rosyjsku „tapeta”) i nadal widać ją w nazwach plików i katalogów cache.

## O tym projekcie

Jestem Alex. Chcę uczciwie powiedzieć, jak powstał Skindancer: nie napisałem jego kodu. Cały kod napisał Claude, sztuczna inteligencja firmy Anthropic, w Claude Code. Moja rola polegała na tym, żeby wiedzieć, czego chcę: pięknego selektora tapet, który działa od razu na DMS i którym mógłbym podzielić się z innymi. Opisywałem, co ma być, oglądałem każdą wersję, wiele razy mówiłem „nie, nie tak”, decydowałem, co zostaje, a co odpada, i testowałem to na własnych komputerach.

Słabo znam angielski. Zgłoszenia (issues) będę czytać i odpowiadać na nie przez tłumacza, więc piszcie prosto i wybaczcie, jeśli moje odpowiedzi zabrzmią dziwnie. Zgłoszenia i pull requesty w dowolnym języku są mile widziane.

## Licencja

GPL-3.0-or-later, zobacz [LICENSE](LICENSE). Ikony i shadery powstały specjalnie dla tego projektu. Obrazy widoczne na podglądach należą do swoich autorów i nie są częścią projektu.
