<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, un selettore di sfondi surreale per DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
<a href="README.de.md">Deutsch</a> ·
<a href="README.es.md">Español</a> ·
<a href="README.fr.md">Français</a> ·
<b>Italiano</b> ·
<a href="README.pt_BR.md">Português (BR)</a> ·
<a href="README.nl.md">Nederlands</a> ·
<a href="README.pl.md">Polski</a> ·
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

Un selettore di sfondi per [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) ispirato a Salvador Dalí: un overlay a tutto schermo con ricerca, preferiti, tre viste, transizioni con shader e la ricerca su wallhaven.cc integrata. È un plugin per DMS e funziona subito su niri, Hyprland e sugli altri compositor supportati da DMS.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Transizioni con shader: grow, melt, ink e iris"></p>

**Lo sfondo non cambia e basta, si trasforma.** Una scheda esce dalla striscia e si ingrandisce fino a riempire lo schermo, la vecchia immagine si scioglie e cola a gocce, ci si rovescia sopra dell'inchiostro oppure si apre una pupilla sull'immagine successiva. Cinque transizioni (grow, iris, dissolve, melt, ink), scelte a caso o fissate nelle impostazioni, oppure nessuna.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Vista a striscia: schede inclinate che ondeggiano come gelatina"></p>

**Una striscia di schede inclinate con un effetto gelatina.** Scorri e le schede si allungano, vanno un po' oltre e poi si assestano.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="La ricerca restringe la striscia mentre scrivi"></p>

**Ricerca.** Per nome del file, titolo, descrizione e tag. Titoli e tag possono stare in un piccolo file sidecar accanto all'immagine (`.oboi/<nome>.json`), e le immagini salvate da wallhaven li ricevono in automatico. A scelta, un modello SigLIP2 locale aggiunge la ricerca per significato: parole inglesi come `desert` o `rain` trovano le immagini giuste anche senza tag.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Vista muro: una griglia in cui saltare da una cella all'altra"></p>

**Muro.** Tutta la libreria in un colpo d'occhio; con le frecce salti da una cella all'altra.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Vista profondità: schede impilate verso il fondo"></p>

**Profondità.** Le schede si allontanano nella scena come un mazzo di cartoline.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: cerca, filtra, salva, poi applica"></p>

**wallhaven integrato.** Cerca su wallhaven.cc direttamente dal selettore, con filtri per risoluzione, proporzioni, ordinamento, categorie e purezza. Con Invio l'immagine viene salvata nella cartella degli sfondi insieme ai suoi tag e compare nella tua libreria.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Impostazioni: menu a tendina che si srotolano come un telo morbido e gocciolano"></p>

**Impostazioni dentro il selettore.** Ogni opzione è un menu a tendina che si srotola come un telo morbido e sgocciola dal bordo. L'interfaccia parla 14 lingue e segue la lingua di DMS.

## Installazione

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Poi attiva **Skindancer** in Impostazioni di DMS → Plugin. (Se hai impostato `XDG_CONFIG_HOME`, la cartella è `$XDG_CONFIG_HOME/dms/plugins`.)

Il selettore ha bisogno di piccoli programmi di supporto per l'indicizzazione, le miniature e wallhaven. Ci sono due modi per averli:

- **Binario precompilato, non serve installare altro.** Scarica `oboi-helper` dall'[ultima release](https://github.com/Alastor1991/skindancer/releases/latest) nella cartella `bin` del plugin e rendilo eseguibile:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Include già Python, Pillow, numpy, onnxruntime e tokenizers e gira su qualsiasi Linux x86_64 con glibc 2.28 o successiva. La release contiene anche `oboi-helper.sha256`. Puoi compilarlo da solo con `tools/build-helper.sh` (servono podman o docker).
- **Python di sistema.** `python3` e Pillow (`python-pillow` su Arch, `python3-pil` su Debian e Ubuntu, `python3-pillow` su Fedora, `python313-Pillow` su openSUSE). Per la ricerca per significato servono anche onnxruntime, tokenizers e numpy.

La ricerca per significato è facoltativa e richiede i file del modello (circa 410 MB): esegui `tools/get-model.sh`. Senza questi file il selettore cerca per parole.

### NixOS

Il plugin richiede DMS 2.1.2 o versioni successive. nixpkgs 26.05 include DMS 1.4.6, quindi prendi il pacchetto DMS dal suo flake e aggiungi Skindancer come plugin dichiarativo:

```nix
# input del flake
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
      hash = "";   # nix stampa l'hash giusto alla prima build
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Poi attiva il plugin in Impostazioni di DMS → Plugin. Il binario precompilato `oboi-helper` su NixOS non parte senza `programs.nix-ld.enable = true`; senza questa opzione Skindancer usa il Python indicato sopra, che su NixOS è la strada normale. Per la ricerca per significato aggiungi `ps.onnxruntime ps.tokenizers ps.numpy` ai pacchetti Python. Su NixOS funziona anche un semplice `git clone` in `~/.config/dms/plugins`.

## Uso

- **Aprire il selettore:** `dms ipc call skindancer picker`. Associalo a una scorciatoia nel tuo compositor, per esempio in niri: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Oppure attiva **Menu del clic destro sul desktop** nelle impostazioni del plugin: sostituisce il menu del desktop di DMS con quello di Skindancer, e se lo disattivi torna quello di DMS. Su labwc, Sway, Scroll e KWin il compositor tiene per sé i clic sul desktop, quindi lì (come succede con DMS) il menu resta disattivato e si usa una scorciatoia.
- **Tasti:** ← → per sfogliare, ↑ ↓ per spostarsi di riga nelle griglie, Invio imposta lo sfondo, Ctrl+D aggiunge ai preferiti, Ctrl+1 2 3 cambiano vista, Ctrl+4 apre wallhaven, F1 aiuto, Esc chiude. L'ingranaggio apre le impostazioni.
- **Altri comandi IPC:** `random`, `next`, `prev`, `apply`, `find <parole>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <nome>`, `help`, `close`.

Il selettore si apre sul monitor che ha il focus e funziona con gli sfondi impostati per singolo monitor. Su labwc e KWin, DMS non sa quale monitor abbia il focus, quindi indicalo tu: `dms ipc call skindancer pickerOn DP-1` (esistono anche `randomOn <output>` e `menuAtOn <output> <x> <y>`).

## Impostazioni

La pagina del plugin nelle impostazioni di DMS contiene la cartella degli sfondi (se vuota, si usa la cartella dello sfondo attuale oppure la cartella Immagini), il menu col tasto destro e la chiave API di wallhaven. Tutto il resto si imposta dentro il selettore: transizione, vista iniziale, rimbalzo, didascalie, suggerimenti sui tasti, ricerca per significato e la scheda wallhaven con i suoi filtri.

## Cosa scrive e quando va online

- `~/.cache/oboi/dms/`: l'indice e le miniature. Si ricrea se lo cancelli.
- `~/.cache/oboi/helper-<hash>/`: il programma di supporto precompilato si decomprime qui al primo avvio (circa 180 MB). Le vecchie versioni vengono rimosse un giorno dopo l'aggiornamento.
- `~/.local/share/oboi/models/siglip2/`: il modello facoltativo per la ricerca per significato, solo se lo scarichi.
- `<cartella degli sfondi>/.oboi/<file>.json`: i preferiti e, per le immagini salvate da wallhaven, i loro tag e la fonte. Questi piccoli file viaggiano con la cartella se la sincronizzi. Se la cartella è in sola lettura, i preferiti vanno invece in `~/.local/state/oboi/favorites.json`, e le immagini salvate da wallhaven in `<Immagini>/Wallpapers`.
- Rete: solo la scheda wallhaven parla con wallhaven.cc, e solo finché è aperta. Per impostazione predefinita SFW e 4K. Per NSFW serve una tua chiave API di wallhaven; la chiave viene inviata in un'intestazione della richiesta e mai nell'indirizzo.

## Testato su

Installato come descrive questo README, su macchine virtuali pulite con DMS 2.1.2 configurato secondo le istruzioni ufficiali: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 e openSUSE Tumbleweed su niri, Arch Linux su Hyprland, Sway e labwc (provati a mano con tastiera e mouse), e NixOS 26.05 con il plugin installato in modo dichiarativo dallo store di Nix. Ognuna è stata provata sia con Python di sistema sia con il binario precompilato (su NixOS il binario ripiega correttamente su Python). Nell'uso quotidiano gira su CachyOS con niri. Gli script di test si trovano in `tools/vm/`.

Non ancora testato: schede video NVIDIA e AMD reali (le macchine virtuali disegnano con virgl, quindi lì non si è potuta valutare la fluidità delle transizioni), più monitor fisici, Gentoo e Void.

## Limiti noti

- Il campo della chiave API nelle impostazioni di DMS mostra la chiave in chiaro: le impostazioni dei plugin di DMS non hanno ancora un campo nascosto.
- Se rimuovi il plugin mentre il suo menu col tasto destro è attivo, riattiva il menu del desktop di DMS nelle impostazioni di DMS (Desktop Widgets → General → Right-click menu).
- Senza GPU (rendering software di Qt) le schede sono semplici rettangoli e gli sfondi cambiano senza transizione.
- Le immagini verticali compaiono solo su un monitor in verticale.

## Il nome

I Danzatori Volto sono i mutaforma di *Dune* di Frank Herbert: assumono qualsiasi volto. È quello che questa utility fa al tuo desktop. In russo il progetto si chiama «Лицедейка» (litsedeyka, «la danzatrice di volti» o «l'attrice»). Il nome provvisorio era Oboi (обои, «sfondo» in russo), e si vede ancora nei nomi dei file e della cache.

## Su questo progetto

Sono Alex. Voglio essere onesto su come è nato Skindancer: il suo codice non l'ho scritto io. L'ha scritto tutto Claude, l'IA di Anthropic, in Claude Code. Il mio contributo è stato sapere cosa volevo: un bel selettore di sfondi che funzionasse subito su DMS e che potessi condividere con altre persone. L'ho descritto, ho guardato ogni versione, ho detto tante volte «no, così no», ho deciso cosa tenere e cosa togliere, e l'ho provato sui miei computer.

Il mio inglese non è buono. Leggerò le issue e risponderò con l'aiuto di un traduttore, quindi scrivete in modo semplice e perdonatemi se le mie risposte suoneranno strane. Issue e pull request in qualsiasi lingua sono benvenute.

## Licenza

GPL-3.0-or-later, vedi [LICENSE](LICENSE). Le icone e gli shader sono stati creati apposta per questo progetto. Le immagini nell'anteprima appartengono ai rispettivi autori e non fanno parte del progetto.
