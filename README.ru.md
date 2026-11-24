<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Лицедейка, сюрреалистичный выбор обоев для DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<b>Русский</b> ·
<a href="README.de.md">Deutsch</a> ·
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

<p align="center">
<a href="https://github.com/Alastor1991/skindancer/releases/latest"><img src="https://img.shields.io/github/v/release/Alastor1991/skindancer?label=release" alt="release"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0--or--later-blue" alt="GPL-3.0-or-later"></a>
<a href="https://github.com/duxlabs-dev/dux-shell"><img src="https://img.shields.io/badge/DMS-2.1.2%2B-8a6cd6" alt="DMS 2.1.2+"></a>
<a href="docs/README.md"><img src="https://img.shields.io/badge/docs-English-informational" alt="technical docs (English)"></a>
</p>

# Лицедейка (Skindancer)

Выбор обоев для [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) в духе Сальвадора Дали. Он открывается поверх всего экрана, и в нём есть поиск, избранное, три вида ленты, шейдерные переходы и встроенный поиск по wallhaven.cc. Лицедейка сделана плагином DMS и работает из коробки на niri, Hyprland и других композиторах, которые поддерживает DMS.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Шейдерные переходы: рост, стекание, чернила и зрачок"></p>

**Одни обои превращаются в другие.** Карточка вырастает из ленты на весь экран, старая картинка стекает каплями, по ней растекаются чернила или раскрывается зрачок, а за ним следующая. Переходов пять (рост, зрачок, растворение, стекание, чернила). Лицедейка выбирает их случайно, но можно закрепить один в настройках или выключить переходы совсем.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Лента: скошенные карточки, которые пружинят, как желе"></p>

**Лента из скошенных карточек, которые пружинят, как желе.** Листаешь, и карточки растягиваются, проскакивают и встают на место.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="Поиск сужает ленту прямо во время набора"></p>

**Поиск** по имени файла, названию, описанию и тегам. Названия и теги можно держать в маленьком файле рядом с картинкой (`.oboi/<имя>.json`), а у картинок, сохранённых с wallhaven, он появляется сам. Если поставить локальную модель SigLIP2, появится поиск по смыслу: английские слова вроде `desert` или `rain` находят подходящие картинки и без тегов.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Стена: сетка, по которой прыгаешь из клетки в клетку"></p>

**Стена** показывает всю библиотеку разом, а стрелки переводят выбор из клетки в клетку.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Глубина: карточки уходят вдаль"></p>

**Глубина:** карточки уходят вглубь сцены, как колода открыток.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: найти, отфильтровать, сохранить и поставить"></p>

**wallhaven прямо в ленте.** Ищешь на wallhaven.cc, не выходя из Лицедейки, с фильтрами по разрешению, пропорциям, порядку, категориям и откровенности (SFW, Sketchy, NSFW). Enter сохраняет картинку с тегами в папку обоев, и она тут же появляется в библиотеке.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Настройки: выпадающие списки раскрываются мягким листом с потёками"></p>

**Настройки прямо в ленте.** Каждый пункт сделан выпадающим списком, который раскрывается мягким листом, и с его края стекают капли. Интерфейс переведён на 14 языков и берёт язык из DMS.

## Установка

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Потом включи **Skindancer** в настройках DMS, раздел «Плагины». Если у тебя задан `XDG_CONFIG_HOME`, папка будет `$XDG_CONFIG_HOME/dms/plugins`.

Индекс, миниатюры и wallhaven обслуживают маленькие программы-помощники. Поставить их можно двумя способами:

- **Готовый бинарник, больше ничего ставить не надо.** Скачай `oboi-helper` из [последнего релиза](https://github.com/Alastor1991/skindancer/releases/latest) в папку `bin` плагина и сделай его исполняемым:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Внутри уже лежат Python, Pillow, numpy, onnxruntime и tokenizers, и он запускается на любом x86_64 Linux с glibc 2.28 и новее. В релизе рядом лежит `oboi-helper.sha256`. Собрать его самому можно скриптом `tools/build-helper.sh`, для этого нужен podman или docker.
- **Системный Python:** `python3` и Pillow (`python-pillow` в Arch, `python3-pil` в Debian и Ubuntu, `python3-pillow` в Fedora, `python313-Pillow` в openSUSE). Для поиска по смыслу ещё onnxruntime, tokenizers и numpy.

Поиск по смыслу необязателен. Ему нужны файлы модели размером около 410 МБ, их скачивает скрипт `tools/get-model.sh`. Без них Лицедейка ищет по словам.

### NixOS

Плагину нужна DMS 2.1.2 или новее, а в nixpkgs 26.05 лежит DMS 1.4.6. Поэтому пакет DMS возьми из её flake, а Лицедейку подключи декларативным плагином:

```nix
# в inputs flake
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
      hash = "";   # при первой сборке nix напишет нужный хэш
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Потом включи плагин в настройках DMS, раздел «Плагины». Готовый `oboi-helper` на NixOS без `programs.nix-ld.enable = true` не запускается. Тогда Лицедейка работает на Python из примера выше, и для NixOS это обычный путь. Для поиска по смыслу добавь в пакеты Python ещё `ps.onnxruntime ps.tokenizers ps.numpy`. Простой `git clone` в `~/.config/dms/plugins` на NixOS тоже работает.

## Как пользоваться

- **Открыть ленту:** `dms ipc call skindancer picker`. Удобно повесить на клавишу в композиторе, например в niri: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. А можно включить в настройках плагина **меню по правому клику на рабочем столе**. Тогда вместо меню рабочего стола DMS открывается меню Лицедейки, а если выключить его обратно, меню DMS вернётся. На labwc, Sway, Scroll и KWin клики по пустому рабочему столу забирает себе сам композитор, поэтому там, как и у DMS, меню не включается и ленту открывают клавишей.
- **Клавиши:** ← → листать, ↑ ↓ по рядам в сетках, Enter поставить обои, Ctrl+D в избранное, Ctrl+1 2 3 сменить вид, Ctrl+4 wallhaven, F1 справка, Esc закрыть. Шестерёнка открывает настройки.
- **Другие команды IPC:** `random`, `next`, `prev`, `apply`, `find <слова>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <имя>`, `help`, `close`.

Лента открывается на мониторе с фокусом и понимает обои, заданные для каждого монитора отдельно. На labwc и KWin DMS не знает, на каком мониторе фокус, поэтому монитор назови сам: `dms ipc call skindancer pickerOn DP-1` (ещё есть `randomOn <монитор>` и `menuAtOn <монитор> <x> <y>`).

## Настройки

На странице плагина в настройках DMS задаются папка с обоями (если пусто, берётся папка текущих обоев или папка «Изображения»), меню по правому клику и ключ API wallhaven. Остальное настраивается прямо в ленте: переход, вид при открытии, упругость, подписи, подсказки по клавишам, поиск по смыслу и вкладка wallhaven с фильтрами.

## Что Лицедейка пишет на диск и когда ходит в сеть

- `~/.cache/oboi/dms/`: индекс и миниатюры. Если удалить, соберутся заново.
- `~/.cache/oboi/helper-<хэш>/`: при первом запуске сюда распаковывается готовый помощник, это около 180 МБ. Старые версии удаляются через сутки после обновления.
- `~/.local/share/oboi/models/siglip2/`: модель для поиска по смыслу. Её здесь нет, пока ты сам её не скачаешь.
- `<папка обоев>/.oboi/<файл>.json`: избранное, а у картинок с wallhaven ещё теги и источник. Эти маленькие файлы переезжают вместе с папкой, если её синхронизировать. Если в папку нельзя писать, избранное хранится в `~/.local/state/oboi/favorites.json`, а картинки с wallhaven сохраняются в `<Изображения>/Wallpapers`.
- В сеть ходит только вкладка wallhaven и только пока она открыта. По умолчанию SFW и 4K. Для NSFW нужен свой ключ API wallhaven. Ключ передаётся в заголовке запроса и в адрес не попадает никогда.

## Где проверено

Я ставил плагин так, как написано здесь, на чистые виртуальные машины с DMS 2.1.2, установленной по официальной инструкции: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 и openSUSE Tumbleweed на niri, Arch Linux на Hyprland, Sway и labwc (там я гонял Лицедейку вживую клавиатурой и мышью) и NixOS 26.05, где плагин ставится декларативно и запускается из хранилища Nix. На каждой Лицедейка работала и с системным Python, и с готовым бинарником (на NixOS бинарник, как и задумано, уступает место Python). Каждый день я пользуюсь ею на CachyOS с niri. Скрипты проверки лежат в `tools/vm/`.

Пока не проверено: настоящие видеокарты NVIDIA и AMD (виртуальные машины рисуют через virgl, и плавность переходов там не оценить), несколько физических мониторов, Gentoo и Void.

## Известные ограничения

- Поле ключа API в настройках DMS показывает ключ открытым текстом, потому что в настройках плагинов DMS пока нет скрытого поля ввода.
- Если удалить плагин, пока его меню по правому клику включено, верни меню стола DMS в настройках DMS («Виджеты стола» → «Общее» → «Меню по правому клику»).
- Без видеокарты (программная отрисовка Qt) карточки становятся простыми прямоугольниками, а обои меняются без перехода.
- Вертикальные картинки видны только на вертикальном мониторе.

## Откуда название

Лицеделы в «Дюне» Фрэнка Герберта умеют принимать любое лицо, и Лицедейка делает то же с рабочим столом. По-английски она Skindancer, потому что имя Facedancer уже занято. Рабочее имя было «Обои», и оно до сих пор видно в именах файлов и папок кэша.

## Об этом проекте

Меня зовут Алекс, и про то, как сделана Лицедейка, скажу честно: код писал не я. Весь его написал Claude, ИИ от Anthropic, в Claude Code. Моё дело было знать, чего я хочу: красивую утилиту для обоев, которая работает на DMS из коробки и которой не стыдно поделиться с людьми. Я описывал, что нужно, смотрел каждую версию, много раз говорил «нет, не так», решал, что остаётся, а что уходит, и проверял всё на своих машинах.

Английский у меня плохой. Issue я читаю и отвечаю на них через переводчик, поэтому пишите попроще и не удивляйтесь, если ответ прозвучит странно. Issue и pull request принимаю на любом языке.

## Лицензия

GPL-3.0-or-later, текст в [LICENSE](LICENSE). Иконки и шейдеры сделаны для этого проекта. Картинки в превью принадлежат своим авторам и в проект не входят.
