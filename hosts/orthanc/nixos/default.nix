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

  # Pin linux-firmware to 20251111 (20251125 has buggy GC 11.5.1 firmware causing ROCm page faults)
  # See: https://bbs.archlinux.org/viewtopic.php?pid=2275272
  nixpkgs.overlays = [
    (final: prev: {
      linux-firmware = prev.linux-firmware.overrideAttrs (old: rec {
        version = "20251111";
        src = prev.fetchzip {
          url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz";
          hash = "sha256-YGcG2MxZ1kjfcCAl6GmNnRb0YI+tqeFzJG0ejnicXqY=";
        };
      });
    })
  ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel 6.18 for full Strix Halo support (GPU + EC firmware)
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # AMD GPU kernel parameters for Strix Halo
  boot.kernelParams = [
    "ttm.pages_limit=27648000"
    "ttm.page_pool_size=27648000"
    "amdgpu.cwsr_enable=0"
  ];

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

  networking.hostName = "orthanc";

  # Set your time zone
  time.timeZone = "America/New_York";

  # Docker
  virtualisation.docker.enable = true;

  # Groups
  users.groups.plugdev = { };

  # User account
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
      "plugdev"
    ];
    openssh.authorizedKeys.keyFiles = [
      (builtins.fetchurl {
        url = "https://github.com/qmx.keys";
        sha256 = "0yz3qk6dwfx4jivm7ljd0p6rmqn4rdnbz1gwn7yh5ryy5mcjr2b1";
      })
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    btop-rocm
    neovim
    pciutils
    rocmPackages.rocm-smi
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
  services.fwupd.enable = true;      # Framework firmware updates
  services.timesyncd.enable = true;  # NTP time synchronization

  # YubiKey/Smart Card support
  services.pcscd = {
    enable = true;
    plugins = [ pkgs.ccid ];
  };
  services.udev.packages = [ pkgs.yubikey-personalization ];
  # GROUP-based rules for SSH sessions (TAG+="uaccess" only works for local console)
  services.udev.extraRules = ''
    # YubiKey CCID (smart card interface for GPG)
    ACTION=="add|change", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="plugdev", MODE="0660"
    # YubiKey HID (for OTP, FIDO, etc.)
    ACTION=="add|change", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", GROUP="plugdev", MODE="0660"
  '';

  # NixOS state version
  system.stateVersion = "25.05";
}
