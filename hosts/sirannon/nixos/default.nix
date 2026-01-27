{
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/base.nix
    ../../../modules/nixos/nfs-synology.nix
    ../../../modules/nixos/yubikey.nix
  ];

  # Raspberry Pi 4 boot
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "sirannon";

  # NFS mounts
  nfs-synology = {
    enable = true;
    lazyMounts = [
      "models"
      "backups"
      "media"
    ];
  };

  # WiFi
  networking.wireless = {
    enable = true;
    networks."qmx".psk = "tis8bok5oov1";
  };

  # Extra packages (beyond base.nix)
  environment.systemPackages = with pkgs; [
    neovim
    raspberrypi-eeprom
    tmux
    wget
  ];

  # NixOS state version
  system.stateVersion = "25.05";
}
