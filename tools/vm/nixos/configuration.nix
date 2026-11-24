{ pkgs, sshKey, dmsPkg, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];   # драйверы virtio в initrd, иначе диск не найден
  system.stateVersion = "26.05";
  networking.hostName = "nixos";
  boot.kernelParams = [ "console=ttyS0" ];
  boot.growPartition = true;
  fileSystems."/".autoResize = true;
  image.modules.qemu = { virtualisation.diskSize = "auto"; };

  services.openssh.enable = true;
  users.users.oboi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "render" ];
    initialPassword = "oboi";
    openssh.authorizedKeys.keys = [ sshKey ];
  };
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "oboi";

  # как у обычного пользователя NixOS: niri из nixpkgs, DMS родным модулем, запуск службой
  programs.niri.enable = true;
  programs.dms-shell = {
    enable = true; systemd.enable = true; package = dmsPkg;
    # как ставят плагины на NixOS: декларативно, файлы плагина в /nix/store только для чтения.
    # plugin-src собирает tools/vm/nixos/build.sh из текущего репозитория (вместе с oboi-helper).
    plugins.skindancer = { enable = true; src = ./plugin-src; };
  };
  hardware.graphics.enable = true;
  fonts.packages = [ pkgs.noto-fonts ];

  # Python с Pillow, как его ставят на NixOS (pip в систему нельзя); остальное для проверок
  environment.systemPackages = with pkgs; [ git grim wtype foot curl (python3.withPackages (ps: [ ps.pillow ])) ];

  # вход на tty1 сразу в niri (-l: иначе niri-session перезапускает себя через login-shell)
  environment.loginShellInit = ''
    if [ "$(tty)" = /dev/tty1 ] && [ -z "''${WAYLAND_DISPLAY:-}" ]; then exec niri-session -l >/tmp/session.log 2>&1; fi
  '';
}
