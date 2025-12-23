{
  username,
  homeDirectory,
  ...
}:

{
  imports = [
    ../../../roles/linux-yubikey/home-manager
  ];

  # sirannon - Raspberry Pi 4 NixOS

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };
}
