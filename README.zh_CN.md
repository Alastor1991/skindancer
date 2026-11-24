<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer，为 DMS 打造的超现实主义壁纸选择器"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
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
<b>简体中文</b>
</p>

# Skindancer

一个为 [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell)（DMS）打造的壁纸选择器，颇有萨尔瓦多·达利的风格：全屏浮层，内置搜索、收藏、三种视图和着色器过渡动画，还能直接搜索 wallhaven.cc。它是一个 DMS 插件，在 niri、Hyprland 以及 DMS 支持的其他合成器上开箱即用。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="着色器过渡：生长、熔化、墨水和虹膜"></p>

**壁纸不只是被换掉，而是在变形。** 一张卡片从卡片带里长出来，铺满整个屏幕；旧图像一滴一滴地熔化流走；墨水在画面上洇开；或者像瞳孔张开一样，露出下一张。一共五种过渡（生长、虹膜、溶解、熔化、墨水），可以随机选用，也可以在设置里固定一种，或者干脆关掉。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="卡片带视图：倾斜的卡片像果冻一样晃动"></p>

**一条倾斜的卡片带，像果冻一样弹跳。** 快速翻动时，卡片会被拉长、冲过头，再回弹到位。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="边输入边搜索，卡片带随之收窄"></p>

**搜索。** 可以按文件名、标题、描述和标签来找。标题和标签可以存放在图片旁边的一个小附属文件里（`.oboi/<名称>.json`），从 wallhaven 保存的图片会自动带上这些信息。另外还可以接入本地的 SigLIP2 模型，实现语义搜索：输入 `desert` 或 `rain` 这样的英文词，即使图片没有标签也能找到对应的画面。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="墙视图：可以在格子间跳转的网格"></p>

**墙。** 整个图库一览无余，用方向键在格子之间跳转。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="深度视图：卡片向远处层层堆叠"></p>

**深度。** 卡片向画面深处退去，像一叠明信片。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven：搜索、筛选、保存，然后应用"></p>

**内置 wallhaven。** 在选择器里就能搜索 wallhaven.cc，可按分辨率、宽高比、排序、分类和内容分级筛选。按 Enter 会把图片连同标签一起存进你的壁纸文件夹，随后它就会出现在你的图库里。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="设置：下拉列表像一块边缘滴落的软布一样展开"></p>

**设置就在选择器里。** 每个选项都是一个下拉列表，像一块柔软的布一样展开，边缘还会往下滴。界面支持 14 种语言，并跟随 DMS 的语言设置。

## 安装

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

然后在 DMS 的“设置 → 插件”中启用 **Skindancer**。（如果你设置了 `XDG_CONFIG_HOME`，插件文件夹就是 `$XDG_CONFIG_HOME/dms/plugins`。）

选择器需要几个小的辅助程序来建立索引、生成缩略图和访问 wallhaven。这些程序有两种获取方式：

- **预编译的二进制文件，无需安装其他依赖。** 从[最新版本](https://github.com/Alastor1991/skindancer/releases/latest)下载 `oboi-helper`，放进插件的 `bin` 文件夹，并加上可执行权限：
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  它自带 Python、Pillow、numpy、onnxruntime 和 tokenizers，可以在任何 glibc 2.28 或更新版本的 x86_64 Linux 上运行。发布页面上还有 `oboi-helper.sha256`。你也可以用 `tools/build-helper.sh` 自己构建（需要 podman 或 docker）。
- **使用系统 Python。** 需要 `python3` 和 Pillow（Arch 上是 `python-pillow`，Debian 和 Ubuntu 上是 `python3-pil`，Fedora 上是 `python3-pillow`，openSUSE 上是 `python313-Pillow`）。如果要用语义搜索，还需要 onnxruntime、tokenizers 和 numpy。

语义搜索是可选功能，需要模型文件（约 410 MB）：运行 `tools/get-model.sh` 即可获取。没有这些文件时，选择器只按关键词搜索。

## 使用

- **打开选择器：** `dms ipc call skindancer picker`。可以在合成器里把它绑定到一个快捷键，比如在 niri 里：`Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`。也可以在插件设置里打开 **桌面右键菜单**：这会用 Skindancer 的菜单取代 DMS 的桌面菜单，关闭后 DMS 自己的菜单就会恢复。在 labwc、Sway、Scroll 和 KWin 上，桌面上的点击由合成器自己处理，所以在这些合成器上，这个菜单和 DMS 的菜单一样保持关闭，请改用快捷键。
- **按键：** ← → 浏览，↑ ↓ 在网格里按行移动，Enter 设为壁纸，Ctrl+D 加入收藏，Ctrl+1 2 3 切换视图，Ctrl+4 打开 wallhaven，F1 帮助，Esc 关闭。点击齿轮图标可以打开设置。
- **其他 IPC 命令：** `random`、`next`、`prev`、`apply`、`find <words>`、`view slices|wall|depth`、`source local|wallhaven`、`transition <name>`、`help`、`close`。

选择器会在当前获得焦点的显示器上打开，并支持为每个显示器分别设置壁纸。

## 设置

DMS 设置里的插件页面可以设置壁纸文件夹（留空则使用当前壁纸所在的文件夹，或者你的“图片”文件夹）、右键菜单和 wallhaven API 密钥。其余的都在选择器里设置：过渡动画、起始视图、弹跳效果、图片说明、按键提示、语义搜索，以及带筛选条件的 wallhaven 标签页。

## 它会写入什么，什么时候联网

- `~/.cache/oboi/dms/`：索引和缩略图。删掉之后会自动重新生成。
- `<壁纸文件夹>/.oboi/<文件名>.json`：收藏信息，以及从 wallhaven 保存的图片的标签和来源。如果你同步这个文件夹，这些小文件也会随之同步。如果文件夹是只读的，收藏会改存到 `~/.local/state/oboi/favorites.json`。
- 网络：只有 wallhaven 标签页会访问 wallhaven.cc，而且只在该标签页打开时才会联网。默认为 SFW 和 4K。NSFW 需要你自己的 wallhaven API 密钥；密钥放在请求头里发送，绝不会出现在网址中。

## 测试环境

在全新的虚拟机上按本 README 的步骤安装测试，DMS 2.1.2 按官方说明安装：niri 上测试了 Debian 13（Quickshell 0.3.0）、Ubuntu 26.04、Fedora 44 和 openSUSE Tumbleweed，Hyprland 上测试了 Arch Linux，每个系统都分别用系统 Python 和预编译二进制文件测试过。日常使用的是 CachyOS + niri。测试脚本在 `tools/vm/` 里。

尚未测试：真实的 NVIDIA 和 AMD 显卡（虚拟机使用 virgl 渲染，所以没法判断过渡动画是否流畅）、多个物理显示器、NixOS、Gentoo 和 Void。

## 已知限制

- DMS 设置里的 API 密钥输入框会以明文显示密钥：DMS 的插件设置目前还不支持隐藏输入内容。
- 如果在启用右键菜单的情况下卸载了插件，请到 DMS 设置里把 DMS 桌面菜单重新打开（桌面小组件 → 常规 → 右键菜单）。
- 没有 GPU 时（Qt 软件渲染），卡片只是普通矩形，壁纸切换也没有过渡动画。
- 竖版图片只会在竖屏显示器上出现。

## 名字的由来

Face Dancers（变脸者）是弗兰克·赫伯特《沙丘》里的变形者，他们可以换上任何一张脸。这个小工具对你的桌面做的正是这件事。在俄语里，这个项目叫 «Лицедейка»（读作 litsedeyka，意思是“变脸者”或“女演员”）。它最初的暂定名是 Oboi（обои，俄语里的“壁纸”），至今仍能在文件名和缓存名里看到。

## 关于这个项目

我是 Alex。我想坦率地说明 Skindancer 是怎么做出来的：代码不是我写的。全部代码都是 Claude（Anthropic 的 AI）在 Claude Code 里写的。我做的事是想清楚自己要什么：一个漂亮的壁纸选择器，在 DMS 上开箱即用，而且我可以拿出来与别人分享。我把想法描述出来，看过每一个版本，很多次说“不，不是这样”，决定什么保留、什么去掉，并且在自己的机器上做了测试。

我的英语不好。我会借助翻译工具来阅读和回复 issue，所以请尽量写得简单一些，如果我的回复读起来有点奇怪，还请见谅。欢迎用任何语言提交 issue 和 pull request。

## 许可证

GPL-3.0-or-later，详见 [LICENSE](LICENSE)。图标和着色器是专门为这个项目制作的。预览中的图片归各自的作者所有，不属于本项目。
