<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, un sélecteur de fonds d'écran surréaliste pour DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
<a href="README.de.md">Deutsch</a> ·
<a href="README.es.md">Español</a> ·
<b>Français</b> ·
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

Un sélecteur de fonds d'écran pour [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS), dans l'esprit de Salvador Dalí : une surcouche plein écran avec recherche, favoris, trois vues, transitions par shaders et recherche wallhaven.cc intégrée. C'est un plugin DMS qui fonctionne directement, sans rien configurer, sur niri, Hyprland et les autres compositeurs pris en charge par DMS.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Transitions par shaders : expansion, fonte, encre et iris"></p>

**Le fond d'écran ne se contente pas de changer, il se métamorphose.** Une carte sort de la bande pour remplir l'écran, l'ancienne image fond en coulant goutte à goutte, de l'encre se répand dessus, ou une pupille s'ouvre sur la suivante. Cinq transitions (expansion, iris, dissolution, fonte, encre), tirées au hasard ou fixées dans les réglages, ou aucune.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Vue en bande : des cartes inclinées qui tremblotent comme de la gelée"></p>

**Une bande de cartes inclinées qui rebondissent comme de la gelée.** Quand vous faites défiler, les cartes s'étirent, dépassent leur position et se remettent en place.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="La recherche réduit la bande au fil de la frappe"></p>

**Recherche.** Par nom de fichier, titre, description et étiquettes. Les titres et les étiquettes peuvent se trouver dans un petit fichier annexe à côté de l'image (`.oboi/<nom>.json`), et les images enregistrées depuis wallhaven les reçoivent automatiquement. En option, un modèle SigLIP2 local ajoute la recherche sémantique : des mots anglais comme `desert` ou `rain` trouvent les images correspondantes, même sans étiquettes.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Vue mur : une grille où l'on saute de case en case"></p>

**Mur.** Toute la bibliothèque d'un coup d'œil ; les touches fléchées font sauter de case en case.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Vue profondeur : des cartes empilées vers le fond"></p>

**Profondeur.** Les cartes s'enfoncent dans la scène comme un paquet de cartes postales.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven : chercher, filtrer, enregistrer, puis appliquer"></p>

**wallhaven intégré.** Cherchez sur wallhaven.cc directement depuis le sélecteur, avec des filtres de résolution, de format, de tri, de catégories et de contenu. La touche Enter enregistre l'image dans votre dossier de fonds d'écran avec ses étiquettes, et elle apparaît dans votre bibliothèque.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Réglages : des listes déroulantes qui se déplient comme une feuille souple avec des gouttes"></p>

**Les réglages directement dans le sélecteur.** Chaque option est une liste déroulante qui se déplie comme une feuille souple et dégouline sur le bord. L'interface est disponible en 14 langues et suit la langue de DMS.

## Installation

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Activez ensuite **Skindancer** dans DMS Settings → Plugins. (Si vous avez défini `XDG_CONFIG_HOME`, le dossier est `$XDG_CONFIG_HOME/dms/plugins`.)

Le sélecteur a besoin de petits programmes auxiliaires pour l'indexation, les miniatures et wallhaven. Il y a deux façons de les fournir :

- **Binaire précompilé, rien d'autre à installer.** Téléchargez `oboi-helper` depuis la [dernière version](https://github.com/Alastor1991/skindancer/releases/latest) dans le dossier `bin` du plugin et rendez-le exécutable :
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Il embarque Python, Pillow, numpy, onnxruntime et tokenizers, et tourne sur n'importe quel Linux x86_64 avec glibc 2.28 ou ultérieure. La version publiée contient aussi `oboi-helper.sha256`. Vous pouvez le compiler vous-même avec `tools/build-helper.sh` (podman ou docker requis).
- **Python du système.** `python3` et Pillow (`python-pillow` sur Arch, `python3-pil` sur Debian et Ubuntu, `python3-pillow` sur Fedora, `python313-Pillow` sur openSUSE). Pour la recherche sémantique, il faut aussi onnxruntime, tokenizers et numpy.

La recherche sémantique est facultative et demande les fichiers du modèle (environ 410 Mo) : lancez `tools/get-model.sh`. Sans eux, le sélecteur cherche par mots.

### NixOS

Le plugin demande DMS 2.1.2 ou plus récent. Or nixpkgs 26.05 ne fournit que DMS 1.4.6 ; prenez donc le paquet DMS depuis son flake, puis ajoutez Skindancer comme plugin déclaratif :

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
      hash = "";   # nix affiche le bon hash à la première compilation
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Activez ensuite le plugin dans DMS Settings → Plugins. Le binaire précompilé `oboi-helper` ne tourne pas sur NixOS sans `programs.nix-ld.enable = true` ; sans cette option, Skindancer utilise le Python ci-dessus, et c'est la méthode habituelle sur NixOS. Pour la recherche sémantique, ajoutez `ps.onnxruntime ps.tokenizers ps.numpy` aux paquets Python. Un simple `git clone` dans `~/.config/dms/plugins` fonctionne aussi sur NixOS.

## Utilisation

- **Ouvrir le sélecteur :** `dms ipc call skindancer picker`. Associez cette commande à une touche dans votre compositeur, par exemple dans niri : `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Vous pouvez aussi activer **Menu du clic droit sur le bureau** dans les réglages du plugin : cela remplace le menu de bureau de DMS par celui de Skindancer, et le désactiver rétablit le menu de DMS. Sur labwc, Sway, Scroll et KWin, le compositeur garde pour lui les clics sur le bureau ; le menu reste donc désactivé (comme dans DMS) et il faut passer par une touche.
- **Touches :** ← → pour parcourir, ↑ ↓ pour changer de ligne dans les grilles, Enter définit le fond d'écran, Ctrl+D ajoute aux favoris, Ctrl+1 2 3 changent de vue, Ctrl+4 ouvre wallhaven, F1 affiche l'aide, Esc ferme. L'engrenage ouvre les réglages.
- **Autres commandes IPC :** `random`, `next`, `prev`, `apply`, `find <mots>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <nom>`, `help`, `close`.

Le sélecteur s'ouvre sur l'écran qui a le focus et gère un fond d'écran différent sur chaque écran. Sur labwc et KWin, DMS ne sait pas quel écran a le focus : indiquez-le donc vous-même avec `dms ipc call skindancer pickerOn DP-1` (il existe aussi `randomOn <output>` et `menuAtOn <output> <x> <y>`).

## Réglages

La page du plugin dans les réglages de DMS contient le dossier de fonds d'écran (s'il est vide, c'est le dossier du fond d'écran actuel, ou votre dossier Images), le menu du clic droit et la clé d'API wallhaven. Tout le reste se règle dans le sélecteur : transition, vue de départ, rebond, légendes, rappel des raccourcis, recherche sémantique et l'onglet wallhaven avec ses filtres.

## Ce que le plugin écrit et quand il se connecte à Internet

- `~/.cache/oboi/dms/` : l'index et les miniatures. Recréés si vous les supprimez.
- `~/.cache/oboi/helper-<hash>/` : le binaire précompilé s'y décompresse au premier lancement (environ 180 Mo). Les anciennes versions sont supprimées un jour après une mise à jour.
- `~/.local/share/oboi/models/siglip2/` : le modèle facultatif pour la recherche sémantique, uniquement si vous le téléchargez.
- `<dossier de fonds d'écran>/.oboi/<fichier>.json` : les favoris et, pour les images enregistrées depuis wallhaven, leurs étiquettes et leur source. Ces petits fichiers suivent le dossier si vous le synchronisez. Si le dossier est en lecture seule, les favoris vont dans `~/.local/state/oboi/favorites.json`, et les images enregistrées depuis wallhaven dans `<Images>/Wallpapers`.
- Réseau : seul l'onglet wallhaven contacte wallhaven.cc, et uniquement tant qu'il est ouvert. SFW et 4K par défaut. Le contenu NSFW nécessite votre propre clé d'API wallhaven ; la clé est envoyée dans un en-tête de requête, jamais dans l'adresse.

## Testé sur

Installé comme l'explique ce README, sur des machines virtuelles propres avec DMS 2.1.2 installé selon les instructions officielles : Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 et openSUSE Tumbleweed sous niri, Arch Linux sous Hyprland, Sway et labwc (manipulés en direct au clavier et à la souris), et NixOS 26.05 avec le plugin installé de façon déclarative depuis le store Nix. Chacune a été vérifiée avec le Python du système et avec le binaire précompilé (sur NixOS, le binaire se rabat correctement sur Python). L'usage quotidien se fait sur CachyOS avec niri. Les scripts de test sont dans `tools/vm/`.

Pas encore testé : de vraies cartes NVIDIA et AMD (les machines virtuelles dessinent avec virgl, donc la fluidité des transitions n'a pas pu y être évaluée), plusieurs écrans physiques, Gentoo et Void.

## Limites connues

- Le champ de la clé d'API dans les réglages de DMS affiche la clé en clair : les réglages des plugins DMS n'ont pas encore de champ masqué.
- Si vous supprimez le plugin alors que son menu du clic droit est activé, réactivez le menu de bureau de DMS dans les réglages de DMS (Desktop Widgets → General → Right-click menu).
- Sans GPU (rendu logiciel de Qt), les cartes sont de simples rectangles et les fonds d'écran changent sans transition.
- Les images en format portrait n'apparaissent que sur un écran en portrait.

## Le nom

Les Danseurs-Visages (Face Dancers) sont les métamorphes du roman *Dune* de Frank Herbert : ils prennent n'importe quel visage. Voilà ce que cet utilitaire fait à votre bureau. En russe, le projet s'appelle «Лицедейка» (litsedeyka, « la danseuse de visages » ou « la comédienne »). Son nom provisoire était Oboi (обои, « fond d'écran » en russe), et on le retrouve encore dans les noms de fichiers et de cache.

## À propos de ce projet

Je m'appelle Alex. Je tiens à être honnête sur la façon dont Skindancer a été créé : je n'ai pas écrit son code. Tout a été écrit par Claude, l'IA d'Anthropic, dans Claude Code. Ma part a été de savoir ce que je voulais : un beau sélecteur de fonds d'écran qui fonctionne directement sur DMS et que je puisse partager avec d'autres personnes. Je l'ai décrit, j'ai regardé chaque version, j'ai dit « non, pas comme ça » bien des fois, j'ai décidé de ce qui restait et de ce qui partait, et je l'ai testé sur mes propres machines.

Mon anglais n'est pas bon. Je lirai les issues et j'y répondrai à l'aide d'un traducteur : merci donc d'écrire simplement, et pardonnez-moi si mes réponses semblent étranges. Les issues et les pull requests dans toutes les langues sont les bienvenues.

## Licence

GPL-3.0-or-later, voir [LICENSE](LICENSE). Les icônes et les shaders ont été créés pour ce projet. Les images de l'aperçu appartiennent à leurs auteurs et ne font pas partie du projet.
