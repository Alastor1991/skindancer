<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, DMS için gerçeküstü bir duvar kağıdı seçici"></p>

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
<b>Türkçe</b> ·
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

[DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) için Salvador Dalí ruhunda bir duvar kağıdı seçici. Tam ekran açılan bir katman olarak gelir ve içinde arama, favoriler, üç görünüm, shader geçişleri ve yerleşik wallhaven.cc araması bulunur. Bir DMS eklentisidir ve niri, Hyprland ile DMS'in desteklediği diğer kompozitörlerde kutudan çıktığı gibi çalışır.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Shader geçişleri: büyüme, erime, mürekkep ve iris"></p>

**Duvar kağıdı sadece değişmez, başkalaşır.** Şeritteki bir kart büyüyüp ekranı kaplar, eski resim damla damla erir, üzerine mürekkep yayılır ya da bir gözbebeği açılıp sıradaki resmi gösterir. Beş geçiş var (büyüme, iris, çözülme, erime, mürekkep). Rastgele seçilebilir, ayarlardan tek birine sabitlenebilir ya da tümüyle kapatılabilir.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Şerit görünümü: jöle gibi sallanan eğik kartlar"></p>

**Jöle gibi esneyen eğik kartlardan bir şerit.** Hızlıca kaydırdığınızda kartlar gerilir, biraz ileri fırlar ve yerine oturur.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="Arama, siz yazdıkça şeridi daraltır"></p>

**Arama.** Dosya adına, başlığa, açıklamaya ve etiketlere göre çalışır. Başlıklar ve etiketler resmin yanındaki küçük bir yan dosyada (`.oboi/<ad>.json`) tutulabilir. wallhaven'dan kaydedilen resimlerin başlık ve etiketleri kendiliğinden eklenir. İsterseniz yerel bir SigLIP2 modeliyle anlamsal arama da kullanabilirsiniz: `desert` ya da `rain` gibi İngilizce sözcükler, etiketi olmasa bile uygun resimleri bulur.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Duvar görünümü: üzerinde hücreden hücreye zıpladığınız bir ızgara"></p>

**Duvar.** Tüm koleksiyon tek bakışta ekrandadır, ok tuşlarıyla hücreden hücreye atlarsınız.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Derinlik görünümü: uzağa doğru dizilen kartlar"></p>

**Derinlik.** Kartlar, bir deste kartpostal gibi sahnenin derinliklerine doğru uzaklaşır.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: ara, filtrele, kaydet, sonra uygula"></p>

**Yerleşik wallhaven.** wallhaven.cc'de doğrudan seçiciden arama yapın. Çözünürlük, en boy oranı, sıralama, kategori ve içerik düzeyi için filtreler var. Enter, resmi etiketleriyle birlikte duvar kağıdı klasörünüze kaydeder ve resim koleksiyonunuzda görünür.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Ayarlar: yumuşak bir örtü gibi açılıp kenarından damlayan açılır listeler"></p>

**Ayarlar seçicinin içinde.** Her seçenek, yumuşak bir örtü gibi açılan ve kenarından damlayan bir açılır listedir. Arayüz 14 dili destekler ve DMS'in diline uyar.

## Kurulum

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Ardından DMS Ayarlar → Eklentiler bölümünden **Skindancer**'ı etkinleştirin. (`XDG_CONFIG_HOME` tanımlıysa klasör `$XDG_CONFIG_HOME/dms/plugins` olur.)

Seçici; dizinleme, küçük resimler ve wallhaven için birkaç ufak yardımcı programa ihtiyaç duyar. Bunları iki yoldan sağlayabilirsiniz:

- **Hazır derlenmiş ikili dosya, başka bir şey kurmanız gerekmez.** `oboi-helper` dosyasını [son sürümden](https://github.com/Alastor1991/skindancer/releases/latest) eklentinin `bin` klasörüne indirin ve çalıştırılabilir yapın:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  İçinde Python, Pillow, numpy, onnxruntime ve tokenizers hazır gelir; glibc 2.28 veya daha yeni olan her x86_64 Linux'ta çalışır. Sürümde `oboi-helper.sha256` dosyası da bulunur. Dilerseniz `tools/build-helper.sh` ile kendiniz derleyebilirsiniz (podman ya da docker gerekir).
- **Sistem Python'u.** `python3` ve Pillow (Arch'ta `python-pillow`, Debian ve Ubuntu'da `python3-pil`, Fedora'da `python3-pillow`, openSUSE'de `python313-Pillow`). Anlamsal arama için ayrıca onnxruntime, tokenizers ve numpy gerekir.

Anlamsal arama isteğe bağlıdır ve model dosyalarına (yaklaşık 410 MB) ihtiyaç duyar: `tools/get-model.sh` betiğini çalıştırın. Bu dosyalar yoksa seçici sözcüklere göre arar.

### NixOS

Eklenti DMS 2.1.2 veya daha yenisini ister. nixpkgs 26.05'te DMS'in 1.4.6 sürümü bulunuyor, bu yüzden DMS paketini kendi flake'inden alın ve Skindancer'ı bildirimsel (declarative) bir eklenti olarak ekleyin:

```nix
# flake girdileri (inputs)
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
      hash = "";   # nix doğru hash'i ilk derlemede yazdırır
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Ardından eklentiyi DMS Ayarlar → Eklentiler bölümünden etkinleştirin. Hazır derlenmiş `oboi-helper`, `programs.nix-ld.enable = true` olmadan NixOS'ta çalışmaz; bu ayar yoksa Skindancer yukarıdaki Python'u kullanır ve NixOS'ta olağan yol da budur. Anlamsal arama için Python paketlerine `ps.onnxruntime ps.tokenizers ps.numpy` ekleyin. NixOS'ta `~/.config/dms/plugins` içine basit bir `git clone` da işe yarar.

## Kullanım

- **Seçiciyi açmak için:** `dms ipc call skindancer picker`. Bunu kompozitörünüzde bir tuşa atayın, örneğin niri'de: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Ya da eklenti ayarlarında **Masaüstünde sağ tık menüsü** seçeneğini açın: bu, DMS'in masaüstü menüsünün yerine Skindancer'ınkini koyar, kapatınca DMS menüsü geri gelir. labwc, Sway, Scroll ve KWin'de masaüstü tıklamalarını kompozitörün kendisi yakalar; bu yüzden bu kompozitörlerde menü (DMS'in kendi menüsü gibi) kapalı kalır ve seçiciyi bir tuşla açarsınız.
- **Tuşlar:** ← → resimler arasında gezinir, ↑ ↓ ızgaralarda satır satır ilerler, Enter duvar kağıdını ayarlar, Ctrl+D favorilere ekler, Ctrl+1 2 3 görünümleri değiştirir, Ctrl+4 wallhaven'ı açar, F1 yardımı gösterir, Esc kapatır. Dişli simgesi ayarları açar.
- **Diğer IPC komutları:** `random`, `next`, `prev`, `apply`, `find <sözcükler>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <ad>`, `help`, `close`.

Seçici, odakta olan monitörde açılır ve monitör başına ayrı duvar kağıdıyla da çalışır. labwc ve KWin'de DMS hangi monitörün odakta olduğunu bilemez, bu yüzden monitörü siz belirtin: `dms ipc call skindancer pickerOn DP-1` (ayrıca `randomOn <output>` ve `menuAtOn <output> <x> <y>` komutları var).

## Ayarlar

DMS ayarlarındaki eklenti sayfasında duvar kağıdı klasörü (boş bırakılırsa mevcut duvar kağıdının klasörü ya da Resimler klasörünüz kullanılır), sağ tık menüsü ve wallhaven API anahtarı bulunur. Geri kalan her şey seçicinin içinden ayarlanır: geçiş, açılış görünümü, esneme, kart yazıları, tuş ipuçları, anlamsal arama ve filtreleriyle wallhaven sekmesi.

## Neyi nereye yazar, ne zaman internete çıkar

- `~/.cache/oboi/dms/`: indeks ve küçük resimler. Silerseniz yeniden oluşturulur.
- `~/.cache/oboi/helper-<hash>/`: hazır derlenmiş yardımcı ilk çalıştırmada kendini buraya çıkarır (yaklaşık 180 MB). Eski sürümler, güncellemeden bir gün sonra silinir.
- `~/.local/share/oboi/models/siglip2/`: anlamsal arama için isteğe bağlı model, yalnızca indirirseniz oluşur.
- `<duvar kağıdı klasörü>/.oboi/<dosya>.json`: favoriler ve wallhaven'dan kaydedilen resimlerin etiketleriyle kaynağı. Bu küçük dosyalar, klasörü eşitlerseniz klasörle birlikte taşınır. Klasör salt okunur durumdaysa favoriler bunun yerine `~/.local/state/oboi/favorites.json` dosyasına gider, wallhaven'dan kaydedilen resimler de `<Resimler>/Wallpapers` klasörüne kaydedilir.
- Ağ: yalnızca wallhaven sekmesi wallhaven.cc'ye bağlanır, o da sadece sekme açıkken. Varsayılan olarak SFW ve 4K seçilidir. NSFW için kendi wallhaven API anahtarınız gerekir. Anahtar adreste değil, istek başlığında gönderilir.

## Nerede denendi

Bu README'deki adımlarla kurulup DMS 2.1.2'nin resmî talimatlarla kurulduğu temiz sanal makinelerde denendi: niri üzerinde Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 ve openSUSE Tumbleweed, Hyprland, Sway ve labwc üzerinde Arch Linux (klavye ve fareyle elle kullanılarak), ayrıca eklentinin Nix deposundan bildirimsel olarak kurulduğu NixOS 26.05. Her birinde hem sistem Python'uyla hem de hazır ikili dosyayla denendi (NixOS'ta ikili dosya çalışmayınca beklendiği gibi Python devreye girer). Günlük olarak CachyOS ve niri üzerinde kullanılıyor. Test betikleri `tools/vm/` içinde.

Henüz denenmeyenler: gerçek NVIDIA ve AMD ekran kartları (sanal makineler virgl ile çizim yapıyor, bu yüzden geçişlerin akıcılığı orada değerlendirilemedi), birden fazla fiziksel monitör, Gentoo ve Void.

## Bilinen sınırlamalar

- DMS ayarlarındaki API anahtarı alanı anahtarı düz metin olarak gösterir: DMS eklenti ayarlarında henüz gizli giriş alanı yok.
- Sağ tık menüsü açıkken eklentiyi kaldırırsanız, DMS masaüstü menüsünü DMS ayarlarından yeniden etkinleştirin (Masaüstü Widget'ları → Genel → Sağ tık menüsü).
- GPU olmadan (Qt yazılımsal çizim) kartlar düz dikdörtgen olur ve duvar kağıtları geçişsiz değişir.
- Dikey resimler yalnızca dikey monitörde görünür.

## Adı

Yüz Dansçıları (Face Dancers), Frank Herbert'in *Dune* romanındaki biçim değiştirenlerdir: istedikleri yüze bürünürler. Bu araç da masaüstünüze aynısını yapar. Rusçada proje «Лицедейка» (litsedeyka, "yüz dansçısı" ya da "oyuncu kadın") diye anılır. Çalışma adı Oboi'ydi (обои, Rusçada "duvar kağıdı"), dosya ve önbellek adlarında hâlâ görülebilir.

## Bu proje hakkında

Ben Alex. Skindancer'ın nasıl yapıldığı konusunda dürüst olmak istiyorum: kodunu ben yazmadım. Kodun tamamını Anthropic'in yapay zekâsı Claude, Claude Code içinde yazdı. Benim işim ne istediğimi bilmekti: DMS'te kutudan çıktığı gibi çalışan ve başkalarıyla paylaşabileceğim güzel bir duvar kağıdı seçici. Bunu anlattım, her sürüme baktım, defalarca "hayır, böyle değil" dedim, neyin kalıp neyin gideceğine karar verdim ve kendi makinelerimde denedim.

İngilizcem iyi değil. Issue'ları okuyup bir çeviri aracıyla yanıtlayacağım, bu yüzden lütfen sade yazın ve cevaplarım tuhaf gelirse hoş görün. Her dilde issue ve pull request memnuniyetle karşılanır.

## Lisans

GPL-3.0-or-later, bkz. [LICENSE](LICENSE). Simgeler ve shader'lar bu proje için yapıldı. Önizlemedeki resimler sahiplerine aittir ve projenin parçası değildir.
