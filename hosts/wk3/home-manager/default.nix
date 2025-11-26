{ username, homeDirectory, ... }:
{
  # wk3 - Linux workstation cluster node (Raspberry Pi, Debian-based)

  imports = [
    ../../../roles/linux-yubikey/home-manager
    ./homebridge.nix
  ];

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";
  };
}
