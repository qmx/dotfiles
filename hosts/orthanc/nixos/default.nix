{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Host-specific overlay for llama-cpp-rocm b7188
  nixpkgs.overlays = [
    (final: prev: {
      llama-cpp-rocm = prev.llama-cpp-rocm.overrideAttrs (old: rec {
        version = "7188";
        src = prev.fetchFromGitHub {
          owner = "ggerganov";
          repo = "llama.cpp";
          rev = "b${version}";
          hash = "sha256-fmnqiDt2735TeUdUJgF+hFYgZ7TCreVHqVKbLYTSGdQ=";
        };
      });
    })
  ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  users.groups.plugdev = {};

  # User account
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" "plugdev" ];
    openssh.authorizedKeys.keyFiles = [
      (builtins.fetchurl {
        url = "https://github.com/qmx.keys";
        sha256 = "1kg319p7xw9m3xl74qq6xlf1dif4xdf43b3dq52qv4cdl3rkwz9w";
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
