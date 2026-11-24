<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, DMS용 초현실적인 배경화면 선택기"></p>

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
<b>한국어</b> ·
<a href="README.zh_CN.md">简体中文</a>
</p>

# Skindancer

[DankMaterialShell](https://github.com/duxlabs-dev/dux-shell)(DMS)용 배경화면 선택기로, 살바도르 달리의 분위기를 담았습니다. 화면 전체를 덮는 오버레이에 검색, 즐겨찾기, 세 가지 보기 방식, 셰이더 전환 효과, 그리고 wallhaven.cc 검색이 들어 있습니다. DMS 플러그인이라서 niri, Hyprland를 비롯해 DMS가 지원하는 컴포지터에서 설치만 하면 바로 동작합니다.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="셰이더 전환 효과: 확대, 녹아내림, 잉크, 홍채"></p>

**배경화면이 그냥 바뀌는 게 아니라 변신합니다.** 띠 위의 카드가 커지면서 화면을 가득 채우기도 하고, 이전 그림이 녹아서 방울방울 흘러내리기도 하고, 그 위로 잉크가 번지기도 하고, 눈동자가 열리며 다음 그림이 나타나기도 합니다. 전환 효과는 다섯 가지(확대, 홍채, 디졸브, 녹아내림, 잉크)이고, 무작위로 고르거나 설정에서 하나만 고정할 수 있으며, 아예 끌 수도 있습니다.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="띠 보기: 젤리처럼 출렁이는 기울어진 카드들"></p>

**젤리처럼 통통 튀는, 기울어진 카드의 띠.** 넘기면 카드가 늘어나고, 살짝 지나쳤다가 제자리로 돌아옵니다.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="입력하는 대로 띠가 좁혀지는 검색"></p>

**검색.** 파일 이름, 제목, 설명, 태그로 찾습니다. 제목과 태그는 그림 옆에 두는 작은 사이드카 파일(`.oboi/<이름>.json`)에 적어 둘 수 있고, wallhaven에서 저장한 그림에는 자동으로 붙습니다. 원한다면 로컬 SigLIP2 모델을 켜서 의미로 검색할 수도 있습니다. `desert`나 `rain` 같은 영어 단어를 넣으면 태그가 없어도 어울리는 그림을 찾아 줍니다.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="벽 보기: 칸에서 칸으로 뛰어다니는 격자"></p>

**벽.** 라이브러리 전체를 한눈에 보여 주고, 방향키로 칸에서 칸으로 옮겨 다닙니다.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="깊이 보기: 멀리 쌓여 가는 카드들"></p>

**깊이.** 카드가 엽서 묶음처럼 장면 안쪽으로 멀어져 갑니다.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: 검색, 필터, 저장, 적용"></p>

**wallhaven 내장.** 선택기를 떠나지 않고 wallhaven.cc를 검색할 수 있습니다. 해상도, 화면 비율, 정렬, 카테고리, 수위(purity) 필터가 있습니다. Enter를 누르면 그림이 태그와 함께 배경화면 폴더에 저장되고, 곧바로 라이브러리에 나타납니다.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="설정: 물방울이 맺힌 부드러운 천처럼 펼쳐지는 드롭다운 목록"></p>

**선택기 안에서 바로 설정.** 모든 항목이 드롭다운 목록이고, 부드러운 천처럼 펼쳐지면서 가장자리에서 물방울이 흘러내립니다. 인터페이스는 14개 언어를 지원하며 DMS의 언어를 따라갑니다.

## 설치

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

그다음 DMS 설정 → 플러그인에서 **Skindancer**를 켜세요. (`XDG_CONFIG_HOME`을 설정해 두었다면 폴더는 `$XDG_CONFIG_HOME/dms/plugins`입니다.)

인덱싱, 썸네일, wallhaven 연동에는 작은 도우미 프로그램이 필요합니다. 준비하는 방법은 두 가지입니다.

- **미리 빌드된 바이너리(따로 설치할 것 없음).** [최신 릴리스](https://github.com/Alastor1991/skindancer/releases/latest)에서 `oboi-helper`를 플러그인의 `bin` 폴더로 내려받고 실행 권한을 주세요.
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Python, Pillow, numpy, onnxruntime, tokenizers가 함께 들어 있고, glibc 2.28 이상인 x86_64 Linux라면 어디서든 실행됩니다. 릴리스에는 `oboi-helper.sha256`도 있습니다. 직접 빌드하려면 `tools/build-helper.sh`를 쓰세요(podman 또는 docker가 필요합니다).
- **시스템 Python.** `python3`과 Pillow가 필요합니다(Arch는 `python-pillow`, Debian과 Ubuntu는 `python3-pil`, Fedora는 `python3-pillow`, openSUSE는 `python313-Pillow`). 의미 검색까지 쓰려면 onnxruntime, tokenizers, numpy도 필요합니다.

의미 검색은 선택 사항이고, 모델 파일(약 410 MB)이 필요합니다. `tools/get-model.sh`를 실행하세요. 모델이 없으면 선택기는 단어로 검색합니다.

### NixOS

플러그인은 DMS 2.1.2 이상이 필요합니다. nixpkgs 26.05에는 DMS 1.4.6이 들어 있으므로, DMS 패키지는 해당 flake에서 가져오고 Skindancer는 선언형 플러그인으로 추가하세요.

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
      hash = "";   # 첫 빌드 때 nix가 올바른 해시를 알려 줍니다
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

그다음 DMS 설정 → 플러그인에서 플러그인을 켜세요. 미리 빌드된 `oboi-helper`는 `programs.nix-ld.enable = true` 없이는 NixOS에서 실행되지 않으며, 이 옵션이 없으면 Skindancer는 위의 Python을 씁니다. NixOS에서는 이쪽이 일반적인 방식입니다. 의미 검색을 쓰려면 Python 패키지에 `ps.onnxruntime ps.tokenizers ps.numpy`를 추가하세요. `~/.config/dms/plugins`에 그냥 `git clone`해도 NixOS에서 동작합니다.

## 사용법

- **선택기 열기:** `dms ipc call skindancer picker`. 컴포지터에서 단축키로 지정해 두면 편합니다. niri라면 예를 들어 `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`처럼 씁니다. 또는 플러그인 설정에서 **바탕화면 우클릭 메뉴**를 켜세요. DMS의 바탕화면 메뉴 대신 Skindancer의 메뉴가 열리고, 끄면 DMS 메뉴가 돌아옵니다. labwc, Sway, Scroll, KWin에서는 바탕화면 클릭을 컴포지터가 직접 가져가므로, 이런 환경에서는 DMS와 마찬가지로 메뉴가 꺼진 채로 유지되니 단축키를 쓰세요.
- **단축키:** ← → 넘겨 보기, ↑ ↓ 격자에서 줄 단위 이동, Enter 배경화면 적용, Ctrl+D 즐겨찾기 추가, Ctrl+1 2 3 보기 전환, Ctrl+4 wallhaven 열기, F1 도움말, Esc 닫기. 톱니바퀴를 누르면 설정이 열립니다.
- **그 밖의 IPC 명령:** `random`, `next`, `prev`, `apply`, `find <단어>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <이름>`, `help`, `close`.

선택기는 포커스가 있는 모니터에서 열리고, 모니터마다 다른 배경화면을 쓰는 환경도 지원합니다. labwc와 KWin에서는 DMS가 어느 모니터에 포커스가 있는지 알 수 없으므로 모니터를 직접 지정하세요: `dms ipc call skindancer pickerOn DP-1` (`randomOn <모니터>`와 `menuAtOn <모니터> <x> <y>`도 있습니다).

## 설정

DMS 설정의 플러그인 페이지에서는 배경화면 폴더(비워 두면 현재 배경화면이 있는 폴더, 없으면 사진 폴더), 우클릭 메뉴, wallhaven API 키를 정합니다. 나머지는 모두 선택기 안에서 설정합니다. 전환 효과, 처음 보기 방식, 출렁임, 캡션, 키 안내, 의미 검색, 그리고 필터가 있는 wallhaven 탭입니다.

## 저장하는 파일과 인터넷 접속

- `~/.cache/oboi/dms/`: 인덱스와 썸네일. 지워도 다시 만들어집니다.
- `~/.cache/oboi/helper-<hash>/`: 미리 빌드된 도우미가 처음 실행될 때 여기에 스스로 압축을 풉니다(약 180 MB). 이전 버전은 업데이트 하루 뒤에 지워집니다.
- `~/.local/share/oboi/models/siglip2/`: 의미 검색용 모델(선택 사항). 직접 내려받은 경우에만 생깁니다.
- `<배경화면 폴더>/.oboi/<파일>.json`: 즐겨찾기, 그리고 wallhaven에서 저장한 그림의 태그와 출처. 이 작은 파일들은 폴더를 동기화하면 함께 따라갑니다. 폴더가 읽기 전용이면 즐겨찾기는 대신 `~/.local/state/oboi/favorites.json`에 저장되고, wallhaven에서 저장한 그림은 `<사진 폴더>/Wallpapers`에 들어갑니다.
- 네트워크: wallhaven 탭만 wallhaven.cc와 통신하며, 그 탭이 열려 있는 동안에만 합니다. 기본값은 SFW와 4K입니다. NSFW는 본인의 wallhaven API 키가 필요하고, 키는 주소가 아니라 요청 헤더에 담겨 전송됩니다.

## 테스트한 환경

이 README에 적힌 방법 그대로, 공식 안내에 따라 DMS 2.1.2를 설치한 깨끗한 가상 머신에서 설치해 보았습니다. niri 환경에서는 Debian 13(Quickshell 0.3.0), Ubuntu 26.04, Fedora 44, openSUSE Tumbleweed를, Hyprland, Sway, labwc 환경에서는 Arch Linux를(키보드와 마우스로 직접 조작하며 확인했습니다), 그리고 플러그인을 Nix 스토어에서 선언형으로 설치한 NixOS 26.05를 썼습니다. 모두 시스템 Python과 미리 빌드된 바이너리 양쪽으로 확인했습니다(NixOS에서는 바이너리 대신 의도한 대로 Python이 쓰입니다). 매일 쓰는 환경은 CachyOS와 niri입니다. 테스트 스크립트는 `tools/vm/`에 있습니다.

아직 테스트하지 못한 것은 실제 NVIDIA와 AMD 그래픽 카드(가상 머신은 virgl로 그리기 때문에 전환 효과가 부드러운지는 판단할 수 없었습니다), 여러 대의 실제 모니터, Gentoo, Void입니다.

## 알려진 제한 사항

- DMS 설정의 API 키 입력란은 키를 그대로 보여 줍니다. DMS 플러그인 설정에는 아직 입력값을 가려 주는 입력란이 없습니다.
- 우클릭 메뉴를 켜 둔 채로 플러그인을 삭제했다면, DMS 설정(바탕화면 위젯 → 일반 → 우클릭 메뉴)에서 DMS의 바탕화면 메뉴를 다시 켜세요.
- GPU가 없으면(Qt 소프트웨어 렌더링) 카드는 평범한 사각형이 되고, 배경화면은 전환 효과 없이 바뀝니다.
- 세로 그림은 세로 모니터에서만 나타납니다.

## 이름에 대하여

페이스 댄서는 프랭크 허버트의 소설 *듄*에 나오는 변신술사로, 어떤 얼굴이든 뒤집어쓸 수 있습니다. 이 도구가 바탕화면에 하는 일이 바로 그것입니다. 러시아어로 이 프로젝트의 이름은 «Лицедейка»(리체데이카, '페이스 댄서' 또는 '여배우'라는 뜻)입니다. 작업용 이름은 Oboi(обои, 러시아어로 '배경화면')였고, 지금도 파일 이름과 캐시 이름에 남아 있습니다.

## 이 프로젝트에 대하여

저는 Alex입니다. Skindancer가 어떻게 만들어졌는지 솔직하게 말씀드리고 싶습니다. 코드는 제가 쓰지 않았습니다. 전부 Anthropic의 AI인 Claude가 Claude Code에서 작성했습니다. 제가 한 일은 무엇을 원하는지 아는 것이었습니다. 제가 원한 것은 DMS에서 설치만 하면 바로 동작하고 다른 사람들과 나눌 수 있는 아름다운 배경화면 선택기였습니다. 저는 그것을 설명했고, 모든 버전을 직접 보았고, "아니, 이건 아니야"라고 여러 번 말했고, 무엇을 남기고 무엇을 뺄지 정했고, 제 컴퓨터들에서 직접 테스트했습니다.

제 영어는 서툽니다. 이슈는 번역기로 읽고 답할 테니 쉬운 문장으로 써 주시고, 제 답변이 어색하더라도 양해해 주세요. 이슈와 풀 리퀘스트는 어떤 언어로 써도 환영합니다.

## 라이선스

GPL-3.0-or-later이며, 자세한 내용은 [LICENSE](LICENSE)를 보세요. 아이콘과 셰이더는 이 프로젝트를 위해 만들었습니다. 미리보기에 쓰인 그림은 각 작가의 것이며 프로젝트에 포함되지 않습니다.
