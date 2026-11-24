<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, un selector de fondos de pantalla surrealista para DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
<a href="README.de.md">Deutsch</a> ·
<b>Español</b> ·
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

Un selector de fondos de pantalla para [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) con el espíritu de Salvador Dalí: una superposición a pantalla completa con búsqueda, favoritos, tres vistas, transiciones con shaders y búsqueda en wallhaven.cc integrada. Es un plugin de DMS y funciona sin configurar nada en niri, Hyprland y los demás compositores compatibles con DMS.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Transiciones con shaders: crecer, derretir, tinta e iris"></p>

**El fondo no solo cambia, se transforma.** Una tarjeta crece desde la tira hasta ocupar toda la pantalla, la imagen anterior se derrite goteando, la tinta se derrama sobre ella o una pupila se abre hacia la siguiente. Hay cinco transiciones (crecer, iris, disolver, derretir, tinta): se eligen al azar, puedes fijar una en los ajustes o desactivarlas todas.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Vista de tira: tarjetas inclinadas que se mueven como gelatina"></p>

**Una tira de tarjetas inclinadas con rebote de gelatina.** Al pasarlas rápido, las tarjetas se estiran, se pasan de largo y vuelven a su sitio.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="La búsqueda reduce la tira mientras escribes"></p>

**Búsqueda.** Por nombre de archivo, título, descripción y etiquetas. Los títulos y las etiquetas pueden guardarse en un archivo auxiliar pequeño junto a la imagen (`.oboi/<nombre>.json`), y las imágenes guardadas desde wallhaven ya los traen de forma automática. Si quieres, un modelo SigLIP2 local añade búsqueda por significado: palabras en inglés como `desert` o `rain` encuentran imágenes que encajan, incluso sin etiquetas.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Vista de muro: una cuadrícula por la que saltas"></p>

**Muro.** Toda la biblioteca de un vistazo; con las flechas saltas de una celda a otra.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Vista de profundidad: tarjetas apiladas hacia el fondo"></p>

**Profundidad.** Las tarjetas se alejan hacia el fondo de la escena como una baraja de postales.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: buscar, filtrar, guardar y aplicar"></p>

**wallhaven integrado.** Busca en wallhaven.cc directamente desde el selector, con filtros de resolución, relación de aspecto, orden, categorías y pureza. Enter guarda la imagen con sus etiquetas en tu carpeta de fondos, y la imagen aparece en tu biblioteca.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Ajustes: listas desplegables que se abren como una tela blanda y gotean"></p>

**Los ajustes, dentro del propio selector.** Cada opción es una lista desplegable que se abre como una tela blanda y gotea por el borde. La interfaz está disponible en 13 idiomas y sigue el idioma de DMS.

## Instalación

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Después activa **Skindancer** en Ajustes de DMS → Plugins. (Si tienes definida `XDG_CONFIG_HOME`, la carpeta es `$XDG_CONFIG_HOME/dms/plugins`.)

El selector necesita unos pequeños programas auxiliares para indexar, generar miniaturas y hablar con wallhaven. Hay dos formas de tenerlos:

- **Binario precompilado, sin instalar nada más.** Descarga `oboi-helper` de la [última versión](https://github.com/Alastor1991/skindancer/releases/latest) en la carpeta `bin` del plugin y hazlo ejecutable:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Incluye Python, Pillow, numpy, onnxruntime y tokenizers, y funciona en cualquier Linux x86_64 con glibc 2.28 o superior. La versión publicada trae también `oboi-helper.sha256`. Puedes compilarlo tú mismo con `tools/build-helper.sh` (necesita podman o docker).
- **Python del sistema.** `python3` y Pillow (`python-pillow` en Arch, `python3-pil` en Debian y Ubuntu, `python3-pillow` en Fedora, `python313-Pillow` en openSUSE). Para la búsqueda por significado hacen falta además onnxruntime, tokenizers y numpy.

La búsqueda por significado es opcional y necesita los archivos del modelo (unos 410 MB): ejecuta `tools/get-model.sh`. Sin ellos, el selector busca por palabras.

## Uso

- **Abrir el selector:** `dms ipc call skindancer picker`. Asígnale un atajo de teclado en tu compositor, por ejemplo en niri: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. O activa **Menú con clic derecho en el escritorio** en los ajustes del plugin: así el menú de escritorio de DMS se sustituye por el de Skindancer, y al desactivarlo vuelve el de DMS. En labwc, Sway, Scroll y KWin el compositor se queda con los clics sobre el escritorio, así que allí (igual que en DMS) el menú queda desactivado y se usa un atajo de teclado.
- **Teclas:** ← → para recorrer, ↑ ↓ para moverte por filas en las cuadrículas, Enter aplica el fondo, Ctrl+D lo añade a favoritos, Ctrl+1 2 3 cambian de vista, Ctrl+4 abre wallhaven, F1 es la ayuda, Esc cierra. El engranaje abre los ajustes.
- **Otros comandos IPC:** `random`, `next`, `prev`, `apply`, `find <palabras>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <nombre>`, `help`, `close`.

El selector se abre en el monitor que tiene el foco y funciona con fondos distintos por monitor.

## Ajustes

La página del plugin en los ajustes de DMS tiene la carpeta de fondos (si la dejas vacía, se usa la carpeta del fondo actual o tu carpeta de Imágenes), el menú del clic derecho y la clave de API de wallhaven. Todo lo demás se configura dentro del selector: transición, vista inicial, rebote, leyendas, atajos en pantalla, búsqueda por significado y la pestaña de wallhaven con sus filtros.

## Qué escribe en disco y cuándo se conecta a internet

- `~/.cache/oboi/dms/`: el índice y las miniaturas. Se vuelven a crear si las borras.
- `<carpeta de fondos>/.oboi/<archivo>.json`: los favoritos y, en las imágenes guardadas desde wallhaven, sus etiquetas y su origen. Estos archivos pequeños viajan con la carpeta si la sincronizas. Si la carpeta es de solo lectura, los favoritos se guardan en `~/.local/state/oboi/favorites.json`.
- Red: solo la pestaña de wallhaven se comunica con wallhaven.cc, y únicamente mientras está abierta. Por defecto, SFW y 4K. Para NSFW hace falta tu propia clave de API de wallhaven; la clave se envía en una cabecera de la petición y nunca en la dirección.

## Dónde se ha probado

Instalado tal como explica este README, en máquinas virtuales limpias con DMS 2.1.2 configurado siguiendo las instrucciones oficiales: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 y openSUSE Tumbleweed con niri, y Arch Linux con Hyprland, cada uno con Python del sistema y con el binario precompilado. Lo uso a diario en CachyOS con niri. Los scripts de prueba están en `tools/vm/`.

Todavía sin probar: tarjetas gráficas NVIDIA y AMD reales (las máquinas virtuales renderizan con virgl, así que allí no se pudo evaluar la fluidez de las transiciones), varios monitores físicos, NixOS, Gentoo y Void.

## Limitaciones conocidas

- El campo de la clave de API en los ajustes de DMS muestra la clave en texto plano: los ajustes de plugins de DMS aún no tienen un campo oculto.
- Si desinstalas el plugin mientras su menú de clic derecho está activo, vuelve a activar el menú de escritorio de DMS en los ajustes de DMS (Widgets de escritorio → General → Menú de clic derecho).
- Sin GPU (renderizado por software de Qt) las tarjetas son simples rectángulos y los fondos cambian sin transición.
- Las imágenes verticales solo aparecen en un monitor vertical.

## El nombre

Los Danzarines Rostro (Face Dancers) son los cambiaformas de *Dune*, de Frank Herbert: pueden ponerse cualquier cara. Eso mismo hace esta utilidad con tu escritorio. En ruso el proyecto se llama «Лицедейка» (litsedeyka, «la bailarina de rostros» o «la actriz»). El nombre de trabajo era Oboi (обои, «fondo de pantalla» en ruso), y todavía se ve en los nombres de archivos y de la caché.

## Sobre este proyecto

Soy Alex. Quiero ser sincero sobre cómo se hizo Skindancer: yo no escribí su código. Lo escribió todo Claude, la IA de Anthropic, en Claude Code. Lo mío fue saber lo que quería: un selector de fondos bonito, que funcione sin configurar nada en DMS y que pueda compartir con otras personas. Lo describí, miré cada versión, dije muchas veces «no, así no», decidí qué se queda y qué se va, y lo probé en mis propios equipos.

Mi inglés no es bueno. Leeré los issues y los responderé con ayuda de un traductor, así que, por favor, escribe de forma sencilla y perdóname si mis respuestas suenan raras. Los issues y los pull requests son bienvenidos en cualquier idioma.

## Licencia

GPL-3.0-or-later, consulta [LICENSE](LICENSE). Los iconos y los shaders se hicieron para este proyecto. Las imágenes de la vista previa pertenecen a sus autores y no forman parte del proyecto.
