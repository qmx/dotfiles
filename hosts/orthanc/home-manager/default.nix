{ username, homeDirectory, pkgs, ... }:

{
  imports = [
    ../../../roles/linux-yubikey/home-manager
  ];

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";
  };

  # Enable llama-swap with ROCm-accelerated llama-cpp
  services.llama-swap = {
    enable = true;
    llamaCppPackage = pkgs.llama-cpp-rocm;
  };
}
