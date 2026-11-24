<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/banner.png" alt="Skindancer, um seletor de wallpapers surreal para o DMS"></p>

<p align="center">
<a href="README.md">English</a> ·
<a href="README.ru.md">Русский</a> ·
<a href="README.de.md">Deutsch</a> ·
<a href="README.es.md">Español</a> ·
<a href="README.fr.md">Français</a> ·
<a href="README.it.md">Italiano</a> ·
<b>Português (BR)</b> ·
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

Um seletor de wallpapers para o [DankMaterialShell](https://github.com/duxlabs-dev/dux-shell) (DMS) no espírito de Salvador Dalí: uma sobreposição em tela cheia com busca, favoritos, três visualizações, transições com shaders e busca no wallhaven.cc embutida. É um plugin do DMS e funciona direto, sem configuração extra, no niri, no Hyprland e nos outros compositores que o DMS suporta.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/transitions.webp" width="960" alt="Transições com shaders: crescer, derreter, tinta e íris"></p>

**O wallpaper não só troca, ele se transforma.** Um cartão cresce a partir da faixa até ocupar a tela inteira, a imagem antiga derrete em gotas, a tinta se espalha por cima dela ou uma pupila se abre para a próxima. São cinco transições (crescer, íris, dissolver, derreter, tinta), escolhidas ao acaso ou fixadas nas configurações. Também dá para desligar todas.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/strip.webp" width="960" alt="Visualização em faixa: cartões inclinados que balançam como gelatina"></p>

**Uma faixa de cartões inclinados que balançam como gelatina.** Ao passar rápido pelas imagens, os cartões esticam, passam do ponto e se acomodam.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/search.webp" width="960" alt="A busca filtra a faixa enquanto você digita"></p>

**Busca.** Por nome de arquivo, título, descrição e tags. Títulos e tags podem ficar em um pequeno arquivo auxiliar (sidecar) ao lado da imagem (`.oboi/<nome>.json`), e as imagens salvas do wallhaven já recebem esses dados automaticamente. Opcionalmente, um modelo SigLIP2 local acrescenta busca por significado: palavras em inglês como `desert` ou `rain` encontram imagens correspondentes mesmo sem tags.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wall.webp" width="960" alt="Visualização em mural: uma grade em que você pula de célula em célula"></p>

**Mural.** A biblioteca inteira à vista; as setas do teclado pulam de célula em célula.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/depth.webp" width="960" alt="Visualização em profundidade: cartões empilhados em direção ao fundo"></p>

**Profundidade.** Os cartões se afastam para dentro da cena como uma pilha de cartões-postais.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/wallhaven.webp" width="960" alt="wallhaven: buscar, filtrar, salvar e aplicar"></p>

**wallhaven embutido.** Busque no wallhaven.cc direto do seletor, com filtros de resolução, proporção, ordenação, categorias e conteúdo (purity). Enter salva a imagem na sua pasta de wallpapers junto com as tags, e ela aparece na sua biblioteca.

<p align="center"><img src="https://github.com/Alastor1991/skindancer/releases/download/media/settings.webp" width="560" alt="Configurações: listas suspensas que se desenrolam como um lençol macio, com gotas"></p>

**Configurações dentro do próprio seletor.** Cada opção é uma lista suspensa que se desenrola como um lençol macio e pinga na borda. A interface fala 14 idiomas e segue o idioma do DMS.

## Instalação

```bash
git clone https://github.com/Alastor1991/skindancer ~/.config/dms/plugins/skindancer
```

Depois ative o **Skindancer** em Configurações do DMS → Plugins. (Se você definiu `XDG_CONFIG_HOME`, a pasta é `$XDG_CONFIG_HOME/dms/plugins`.)

O seletor precisa de pequenos programas auxiliares para indexar, gerar miniaturas e falar com o wallhaven. Dá para obtê-los de duas formas:

- **Binário pronto, sem instalar mais nada.** Baixe o `oboi-helper` da [release mais recente](https://github.com/Alastor1991/skindancer/releases/latest) para a pasta `bin` do plugin e torne-o executável:
  ```bash
  curl -L -o ~/.config/dms/plugins/skindancer/bin/oboi-helper \
      https://github.com/Alastor1991/skindancer/releases/latest/download/oboi-helper
  chmod +x ~/.config/dms/plugins/skindancer/bin/oboi-helper
  ```
  Ele já traz Python, Pillow, numpy, onnxruntime e tokenizers e roda em qualquer Linux x86_64 com glibc 2.28 ou superior. A release também inclui o `oboi-helper.sha256`. Também dá para compilar o binário por conta própria com `tools/build-helper.sh` (precisa de podman ou docker).
- **Python do sistema.** `python3` e Pillow (`python-pillow` no Arch, `python3-pil` no Debian e no Ubuntu, `python3-pillow` no Fedora, `python313-Pillow` no openSUSE). Para a busca por significado, também onnxruntime, tokenizers e numpy.

A busca por significado é opcional e precisa dos arquivos do modelo (cerca de 410 MB): rode `tools/get-model.sh`. Sem eles, o seletor busca só por palavras.

### NixOS

O plugin precisa do DMS 2.1.2 ou mais novo. O nixpkgs 26.05 traz o DMS 1.4.6, então pegue o pacote do DMS pelo flake dele e adicione o Skindancer como plugin declarativo:

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
      hash = "";   # o nix mostra o hash correto no primeiro build
    };
  };
};
environment.systemPackages = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ];
```

Depois ative o plugin em Configurações do DMS → Plugins. O `oboi-helper` pronto não roda no NixOS sem `programs.nix-ld.enable = true`; sem isso o Skindancer usa o Python acima, que é o jeito normal no NixOS. Para a busca por significado, acrescente `ps.onnxruntime ps.tokenizers ps.numpy` aos pacotes do Python. Um `git clone` simples em `~/.config/dms/plugins` também funciona no NixOS.

## Uso

- **Abrir o seletor:** `dms ipc call skindancer picker`. Associe o comando a um atalho no seu compositor, por exemplo no niri: `Mod+W { spawn "dms" "ipc" "call" "skindancer" "picker"; }`. Ou ative **Menu do clique direito na área de trabalho** nas configurações do plugin: isso substitui o menu da área de trabalho do DMS pelo do Skindancer, e ao desativar a opção o menu do DMS volta. No labwc, no Sway, no Scroll e no KWin o compositor guarda para si os cliques na área de trabalho, então nesses compositores (assim como no DMS) o menu fica desligado e você usa um atalho de teclado.
- **Teclas:** ← → navegam, ↑ ↓ andam por linhas nas grades, Enter define o wallpaper, Ctrl+D adiciona aos favoritos, Ctrl+1 2 3 trocam a visualização, Ctrl+4 abre o wallhaven, F1 mostra a ajuda, Esc fecha. A engrenagem abre as configurações.
- **Outros comandos IPC:** `random`, `next`, `prev`, `apply`, `find <palavras>`, `view slices|wall|depth`, `source local|wallhaven`, `transition <nome>`, `help`, `close`.

O seletor abre no monitor que está com o foco e funciona com wallpapers diferentes por monitor. No labwc e no KWin o DMS não sabe qual monitor está com o foco, então indique o monitor: `dms ipc call skindancer pickerOn DP-1` (também existem `randomOn <output>` e `menuAtOn <output> <x> <y>`).

## Configurações

A página do plugin nas configurações do DMS tem a pasta de wallpapers (se ficar vazia, vale a pasta do wallpaper atual ou a sua pasta Imagens), o menu de clique direito e a chave de API do wallhaven. O resto se configura dentro do seletor: transição, visualização ao abrir, elasticidade, legendas, dicas de teclas, busca por significado e a aba do wallhaven com seus filtros.

## O que ele grava e quando acessa a internet

- `~/.cache/oboi/dms/`: o índice e as miniaturas. Se você apagar, tudo é recriado.
- `~/.cache/oboi/helper-<hash>/`: o auxiliar pronto se extrai nesta pasta na primeira execução (cerca de 180 MB). As versões antigas são removidas um dia depois de uma atualização.
- `~/.local/share/oboi/models/siglip2/`: o modelo opcional da busca por significado, só se você o baixar.
- `<pasta de wallpapers>/.oboi/<arquivo>.json`: favoritos e, nas imagens salvas do wallhaven, as tags e a origem. Esses arquivos pequenos acompanham a pasta se você a sincronizar. Se a pasta for somente leitura, os favoritos vão para `~/.local/state/oboi/favorites.json`, e as imagens salvas do wallhaven vão para `<Imagens>/Wallpapers`.
- Rede: só a aba do wallhaven fala com o wallhaven.cc, e apenas enquanto está aberta. Por padrão, SFW e 4K. NSFW exige a sua própria chave de API do wallhaven, que é enviada em um cabeçalho da requisição e nunca no endereço.

## Onde foi testado

Instalado do jeito que este README descreve, em máquinas virtuais limpas com o DMS 2.1.2 configurado pelas instruções oficiais: Debian 13 (Quickshell 0.3.0), Ubuntu 26.04, Fedora 44 e openSUSE Tumbleweed com niri, Arch Linux com Hyprland, Sway e labwc (testados na prática, com teclado e mouse) e NixOS 26.05 com o plugin instalado de forma declarativa a partir da Nix store. Cada um foi verificado com o Python do sistema e com o binário pronto (no NixOS o binário recorre ao Python, como esperado). No dia a dia, uso no CachyOS com niri. Os scripts de teste estão em `tools/vm/`.

Ainda não testado: placas NVIDIA e AMD de verdade (as máquinas virtuais desenham com virgl, então não deu para avaliar a fluidez das transições), vários monitores físicos, Gentoo e Void.

## Limitações conhecidas

- O campo da chave de API nas configurações do DMS mostra a chave em texto puro: as configurações de plugins do DMS ainda não têm campo oculto.
- Se você remover o plugin enquanto o menu de clique direito dele estiver ativo, reative o menu da área de trabalho do DMS nas configurações do DMS (Widgets da área de trabalho → Geral → Menu de clique direito).
- Sem GPU (renderização por software do Qt), os cartões viram retângulos simples e os wallpapers trocam sem transição.
- Imagens em retrato só aparecem em um monitor em retrato.

## O nome

Os Dançarinos Faciais (Face Dancers) são os metamorfos de *Duna*, de Frank Herbert: eles assumem qualquer rosto. É isso que este utilitário faz com a sua área de trabalho. Em russo, o projeto se chama «Лицедейка» (litsedeyka, "a dançarina de rostos" ou "a atriz"). O nome provisório era Oboi (обои, "wallpaper" em russo), e ele ainda aparece em nomes de arquivos e de pastas de cache.

## Sobre este projeto

Eu sou o Alex. Quero ser honesto sobre como o Skindancer foi feito: eu não escrevi o código. Ele foi todo escrito pelo Claude, a IA da Anthropic, no Claude Code. A minha parte foi saber o que eu queria: um seletor de wallpapers bonito, que funcionasse direto no DMS e que eu pudesse compartilhar com outras pessoas. Eu descrevi a ideia, olhei cada versão, disse "não, assim não" muitas vezes, decidi o que ficava e o que saía e testei nas minhas próprias máquinas.

O meu inglês não é bom. Vou ler as issues e responder por meio de um tradutor, então escreva de forma simples e me perdoe se as minhas respostas soarem estranhas. Issues e pull requests em qualquer idioma são bem-vindos.

## Licença

GPL-3.0-or-later, veja [LICENSE](LICENSE). Os ícones e os shaders foram feitos para este projeto. As imagens da prévia pertencem aos seus autores e não fazem parte do projeto.
