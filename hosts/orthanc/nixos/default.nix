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

  # User account
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAd6XCf09cO5uPf7IxgWeDq1yMM7AZBVuuyUPj2Awaec8O0JXpJd7xT5HFPAVYCz7ChhGy6s9qUgiCNb5BFGi/ZpbjbUxS/UU0TcjuCF6uOh0o3LgnUWigVq8siRDGg8s6FFN/VQ/aBu9Xd5qS8egTbYoHvafdR2oZJtzEywl9CcqPeJVkcSnaDzqWrVWX4Bv9eWf7EM83jd53p3vRD7DsK7MDyFbvtJDkkDTmQcHOBcT+dcVRzY05PAw6g8VDqDNRYiL9Ih6DvKiiYILZb+OC/+YfbgAChkuDRAgAuVGp0HR0CtzDIYvLbe74BFrw0rog0wYg8jzInhEGXY22g1Kd4tsVSSmNt24TlUf/3W5G4Kryue2MspxopemjyIs3f0nskpAY/e7jFVtJjU9VRm/t3XN8YDxvckpMDWXYzzLj/euUUQ7ZA5W8TQZ7VlcfS1MxM3PshW4HhRiWFvlhZVROuuw0sjwtIb51huvZpncwVqwlCGfHotjmyO0rxByUJRnffY89hIc11m4eaXCuOL2X4Auj2Rn9UL2QEvsXYj1BGISNnciAG/KM5HkFS3TwQgnQB3ranb1l/WEyMfJQe5gdZRjVEXVlLv98+cGl3XFtF7FiB+H7rcVqFi5Af5RmWeZfEjmDSys4WA7ogF6IebI+4lOQjHW9KKfyQTwP+cASQ=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmCcbGU2VzZ5xjksQvbmjBRhC4qdIOF2sWwwm/eYQFC/4oEWSVRZUK6nvO5LVTv+ENZ1mx49iMEFg4KLlEHNr3HzYwKGTaB1xDPqrdZBMD2gZPeETKnsDLnQZs7wn8sdZD7b+er5jt3halbl9xoVeJjofGE8ThUrsoKJB4IqfdmHW7Sf/p+C2c4K5VvGvkbYzf7V8mmhcE4sm3QStQANBA4TtugSaK+cw5wEkW5Y3nKK2MxiZqJAapqsPKcZQDPqJeHSsgRzugqzWsRUGZWKvtQnblHwZgnrAiZNhwsQESqbfwuCkj4oVr5cTbpa467KY9u9lNEdeg18aV7jCdexg5"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCakYmyBkeV9/PUXSMxi9m+agWcEM2AK/IiHmLUh9VZUvmV3qh5x8b/AQKbfhGk9CiO9xan2MWu0QO3d9FTwPDiIB0aTGBKfpngYnL69CmFsB1ln0ziNbpJS+Xr8ZDkr4TdPduHSsnoizU/Swv1BqG+8V/UuS7KScspOl70aShSgQiVTIn8NnJ+QRwIuY1mi263c0x+k2bFJQjKloGy/n7KAN8Ebn0o9G5sbr3L5dg640xG2/dJQQwhoz+oep+lpF3Bpnfk6kFcUjS3fBqyRSKagFNZoJP9HYVEZBKL6/TMhqfLVLaoO1j1PuhS6FLZn0agQ2zLBVYy20dAlKAXQykx"
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    btop-rocm
    llama-cpp-rocm
    mosh
    neovim
    pciutils
    rocmPackages.rocm-smi
    tmux
    vim
    wget
  ];

  # Services
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # NixOS state version
  system.stateVersion = "25.05";
}
