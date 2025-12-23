{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Raspberry Pi 4 boot
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "sirannon";

  # NFS client support
  boot.supportedFilesystems = [ "nfs" ];

  # NFS mounts from Synology NAS
  fileSystems."/mnt/models" = {
    device = "192.168.1.200:/volume1/models";
    fsType = "nfs";
    options = [ "rw" "hard" "intr" "nfsvers=4" "x-systemd.automount" "x-systemd.idle-timeout=600" ];
  };

  fileSystems."/mnt/backups" = {
    device = "192.168.1.200:/volume1/backups";
    fsType = "nfs";
    options = [ "rw" "hard" "intr" "nfsvers=4" "x-systemd.automount" "x-systemd.idle-timeout=600" ];
  };

  fileSystems."/mnt/media" = {
    device = "192.168.1.200:/volume1/media";
    fsType = "nfs";
    options = [ "rw" "hard" "intr" "nfsvers=4" "x-systemd.automount" "x-systemd.idle-timeout=600" ];
  };

  # WiFi
  networking.wireless = {
    enable = true;
    networks."qmx".psk = "tis8bok5oov1";
  };

  # Set your time zone
  time.timeZone = "America/New_York";

  # User account
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [
      (builtins.fetchurl {
        url = "https://github.com/qmx.keys";
        sha256 = "0yz3qk6dwfx4jivm7ljd0p6rmqn4rdnbz1gwn7yh5ryy5mcjr2b1";
      })
    ];
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = with pkgs; [
    git
    neovim
    raspberrypi-eeprom
    tmux
    vim
    wget
  ];

  # Enable zsh system-wide (required for user shell)
  programs.zsh.enable = true;
  programs.mosh.enable = true;

  # Services
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # NixOS state version
  system.stateVersion = "25.05";
}
