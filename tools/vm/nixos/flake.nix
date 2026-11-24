# Образ NixOS 26.05 с niri и DMS (родной модуль nixpkgs programs.dms-shell) для tools/vm.
# Сборка: tools/vm/nixos/build.sh (в контейнере nixos/nix, нужен /dev/kvm). Ключ ssh берётся из key.pub.
{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
  outputs = { nixpkgs, ... }: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.sshKey = builtins.readFile ./key.pub;
      modules = [ ./configuration.nix ];
    };
  };
}
