<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer、DMS 用のシュールな壁紙ピッカー"></p>

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
<b>日本語</b> ·
<a href="README.ko.md">한국어</a> ·
<a href="README.zh_CN.md">简体中文</a>
</p>

# Skindancer

[DankMaterialShell](https://github.com/duxlabs-dev/dux-shell)（DMS）用の壁紙ピッカーです。サルバドール・ダリを思わせる全画面オーバーレイで、検索、お気に入り、3つの表示モード、シェーダーによる切り替え演出、wallhaven.cc の検索を最初から備えています。DMS のプラグインとして動き、niri や Hyprland をはじめ、DMS が対応するコンポジターならそのまま使えます。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="シェーダーによる切り替え演出：grow、melt、ink、iris"></p>

**壁紙はただ切り替わるのではなく、姿を変えます。** カードが短冊の列から伸びて画面いっぱいに広がったり、古い絵がしずくになって溶け落ちたり、インクが一面に広がったり、瞳が開いて次の絵が現れたりします。演出は5種類（grow、iris、dissolve、melt、ink）で、ランダムに選ぶことも、設定で1つに固定することも、オフにすることもできます。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="短冊表示：ゼリーのように揺れる斜めのカード"></p>

**ゼリーのように弾む、斜めのカードが並んだ短冊表示。** サッとめくると、カードが伸び、勢い余って行き過ぎてから、ぷるんと元の位置に収まります。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="入力するたびに短冊の並びが絞り込まれる検索"></p>

**検索。** ファイル名、タイトル、説明、タグで探せます。タイトルとタグは、画像と同じ場所に置く小さなサイドカーファイル（`.oboi/<name>.json`）に書いておけます。wallhaven から保存した画像には自動で付きます。オプションで、ローカルの SigLIP2 モデルによる意味検索も使えます。`desert` や `rain` のような英単語で、タグがなくても合う画像が見つかります。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="ウォール表示：セルからセルへ飛び移るグリッド"></p>

**ウォール。** ライブラリ全体を一目で見渡せます。矢印キーでセルからセルへ飛び移ります。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="奥行き表示：奥へ重なっていくカード"></p>

**奥行き。** カードは絵はがきの束のように、奥へ遠ざかっていきます。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven：検索、絞り込み、保存、そして適用"></p>

**wallhaven 内蔵。** ピッカーを離れずに wallhaven.cc を検索できます。解像度、縦横比、並び順、カテゴリ、コンテンツの区分（purity）で絞り込めます。Enter を押すと、タグ付きで壁紙フォルダに保存され、そのままライブラリに加わります。

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="設定：しずくを垂らしながら柔らかい布のように広がるドロップダウン"></p>

**設定もピッカーの中で。** どの項目もドロップダウンで、柔らかい布のように広がり、縁からしずくが垂れます。インターフェースは13言語に対応していて、DMS の言語設定に合わせて切り替わります。

## インストール

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

そのあと、DMS の設定 → Plugins で **Skindancer** をオンにします（`XDG_CONFIG_HOME` を設定している場合、フォルダは `$XDG_CONFIG_HOME/dms/plugins` になります）。

ピッカーは、インデックス作成、サムネイル生成、wallhaven との通信のために小さなヘルパープログラムを使います。用意する方法は2つあります。

- **ビルド済みバイナリ（ほかには何もインストール不要）。** [最新リリース](https://github.com/Alastor1991/skindancer/releases/latest)から `oboi-helper` をプラグインの `bin` フォルダにダウンロードし、実行権限を付けます。
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Python、Pillow、numpy、onnxruntime、tokenizers が同梱されていて、glibc 2.28 以降の x86_64 Linux ならどれでも動きます。リリースには `oboi-helper.sha256` も付いています。自分でビルドすることもでき、その場合は `tools/build-helper.sh` を使います（podman か docker が必要です）。
- **システムの Python。** `python3` と Pillow が必要です（Arch は `python-pillow`、Debian と Ubuntu は `python3-pil`、Fedora は `python3-pillow`、openSUSE は `python313-Pillow`）。意味検索を使うなら、さらに onnxruntime、tokenizers、numpy が要ります。

意味検索はオプションで、モデルファイル（約 410 MB）が必要です。`tools/get-model.sh` を実行して取得してください。モデルがない場合は、通常のキーワード検索になります。

## 使い方

- **ピッカーを開く：** `dms ipc call skindancer picker`。このコマンドをコンポジターでキーに割り当てます。niri なら `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }` のように書きます。または、プラグイン設定で **デスクトップの右クリックメニュー**（Right-click menu on the desktop）をオンにします。DMS のデスクトップメニューが Skindancer のメニューに置き換わり、オフに戻せば DMS のメニューが元に戻ります。labwc、Sway、Scroll、KWin ではデスクトップ上のクリックをコンポジター自身が受け取るので、DMS と同じくメニューはオフのままになり、キーで開くことになります。
- **キー操作：** ← → で前後に移動、↑ ↓ でグリッドの行移動、Enter で壁紙に設定、Ctrl+D でお気に入りに追加、Ctrl+1 2 3 で表示の切り替え、Ctrl+4 で wallhaven を開く、F1 でヘルプ、Esc で閉じる。歯車アイコンで設定が開きます。
- **そのほかの IPC コマンド：** `random`、`next`、`prev`、`apply`、`find <words>`、`view slices|wall|depth`、`source local|wallhaven`、`transition <name>`、`help`、`close`。

ピッカーはフォーカスのあるモニターで開き、モニターごとに壁紙を分けている環境にも対応しています。

## 設定

DMS の設定にあるプラグインのページでは、壁紙フォルダ（空欄なら現在の壁紙があるフォルダ、またはピクチャフォルダ）、右クリックメニュー、wallhaven の API キーを設定します。それ以外の切り替え演出、起動時の表示モード、バウンド、キャプション、キーのヒント、意味検索、絞り込み付きの wallhaven タブは、すべてピッカーの中で設定します。

## 書き込むファイルとネットワーク通信

- `~/.cache/oboi/dms/`：インデックスとサムネイル。消しても再作成されます。
- `<wallpaper folder>/.oboi/<file>.json`：お気に入りと、wallhaven から保存した画像のタグや取得元。フォルダを同期すれば、これらの小さなファイルも一緒に移動します。フォルダが読み取り専用の場合、お気に入りは代わりに `~/.local/state/oboi/favorites.json` に保存されます。
- 通信：wallhaven.cc と通信するのは wallhaven タブだけで、タブを開いている間に限ります。初期設定は SFW と 4K です。NSFW を使うには自分の wallhaven API キーが必要で、キーはリクエストヘッダーで送られ、URL には含まれません。

## 動作確認

この README のとおりにインストールし、公式の手順で DMS 2.1.2 を入れたまっさらな仮想マシンで確認しました。niri では Debian 13（Quickshell 0.3.0）、Ubuntu 26.04、Fedora 44、openSUSE Tumbleweed、Hyprland では Arch Linux で、どれもシステムの Python とビルド済みバイナリの両方を試しています。普段は niri を使った CachyOS で使っています。テスト用スクリプトは `tools/vm/` にあります。

まだ確認できていないもの：実機の NVIDIA と AMD のグラフィックスカード（仮想マシンは virgl で描画するため、切り替え演出の滑らかさは判断できませんでした）、複数の物理モニター、NixOS、Gentoo、Void。

## 既知の制限

- DMS 設定の API キー欄では、キーが平文のまま表示されます。DMS のプラグイン設定には、まだ入力内容を隠す（マスク表示する）欄がないためです。
- 右クリックメニューをオンにしたままプラグインを削除した場合は、DMS の設定で DMS のデスクトップメニューをオンに戻してください（Desktop Widgets → General → Right-click menu）。
- GPU がない環境（Qt のソフトウェアレンダリング）では、カードはただの長方形になり、壁紙は演出なしで切り替わります。
- 縦長の画像は、縦向きのモニターでしか表示されません。

## 名前について

Face Dancer（フェイス・ダンサー）は、フランク・ハーバートの『デューン』に登場する、姿を自在に変える者たちで、どんな顔にでもなれます。このツールがデスクトップに対してやっているのも同じことです。ロシア語ではこのプロジェクトを «Лицедейка»（litsedeyka、「フェイス・ダンサー」や「女優」といった意味）と呼びます。開発中の仮の名前は Oboi（обои、ロシア語で「壁紙」）で、いまもファイル名やキャッシュ名に残っています。

## このプロジェクトについて

Alex です。Skindancer がどう作られたかについて、正直にお話しします。コードは私が書いたものではありません。すべて Anthropic の AI である Claude が、Claude Code の中で書きました。私の役目は、自分が何を求めているのかをはっきり分かっていることでした。求めていたのは、DMS でそのまま動いて、ほかの人にも使ってもらえる、きれいな壁紙ピッカーです。私はそれを言葉で説明し、すべてのバージョンを見て、「いや、こうじゃない」と何度も言い、何を残して何を捨てるかを決め、自分のマシンでテストしました。

私の英語は上手ではありません。Issue は翻訳ツールを使って読み、返信します。そのため、できるだけ簡単な文章で書いてください。返事の言い回しがおかしくても、許してください。Issue と Pull Request は、どの言語でも歓迎します。

## ライセンス

GPL-3.0-or-later です。詳しくは [LICENSE](LICENSE) をご覧ください。アイコンとシェーダーはこのプロジェクトのために作ったものです。プレビューに使っている画像は各作者のもので、プロジェクトには含まれません。
