{
  pkgs,
  username,
  sops-nix,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/base.nix
    ../../../modules/nixos/nfs-synology.nix
    ../../../modules/nixos/yubikey.nix
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

  networking.hostName = "orthanc";

  # NFS mounts
  nfs-synology = {
    enable = true;
    lazyMounts = [
      "models"
      "backups"
      "media"
      "nix-cache"
    ];
  };

  # Docker
  virtualisation.docker.enable = true;

  # Add docker group (merged with wheel from base.nix and plugdev from yubikey.nix)
  users.users.${username}.extraGroups = [ "docker" ];

  # Extra packages (beyond base.nix)
  environment.systemPackages = with pkgs; [
    btop-rocm
    neovim
    pciutils
    rocmPackages.rocm-smi
    tmux
    wget
  ];

  # Framework firmware updates
  services.fwupd.enable = true;

  # NixOS state version
  system.stateVersion = "25.05";
}
