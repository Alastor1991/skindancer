# Образ NixOS 26.05 с niri и DMS для tools/vm. Модуль nixpkgs programs.dms-shell, но пакет DMS из
# официального flake (ветка stable): в nixpkgs 26.05 лежит DMS 1.4.6, а плагину нужна 2.1.2 и новее.
# Сборка: tools/vm/nixos/build.sh (в контейнере nixos/nix, нужен /dev/kvm). Ключ ssh берётся из key.pub.
{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
  # архив ветки, а не github:…: так nix не ходит в API GitHub и не упирается в его лимит
  inputs.dms = { url = "https://github.com/duxlabs-dev/dux-shell/archive/refs/heads/stable.tar.gz"; inputs.nixpkgs.follows = "nixpkgs"; };
  outputs = { nixpkgs, dms, ... }: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { sshKey = builtins.readFile ./key.pub; dmsPkg = dms.packages.x86_64-linux.default; };
      modules = [ ./configuration.nix ];
    };
  };
}
