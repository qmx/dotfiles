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

  # Host-specific overlay for llama-cpp-rocm b7315
  nixpkgs.overlays = [
    (final: prev: {
      llama-cpp-rocm = prev.llama-cpp-rocm.overrideAttrs (old: rec {
        version = "7315";
        src = prev.fetchFromGitHub {
          owner = "ggerganov";
          repo = "llama.cpp";
          rev = "b${version}";
          hash = "sha256-5csvHyGqZhLf04+58Eco1QqSW0WQ564pHqa29Dwgqlw=";
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
    llama-cpp-rocm
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
