{ username, homeDirectory, ... }:
{
  # k01 - Linux workstation cluster node (Raspberry Pi, Debian-based)

  imports = [
    ../../../roles/linux-yubikey/home-manager
  ];

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";
  };
}
