{
  username,
  homeDirectory,
  ...
}:

{
  # sirannon - Raspberry Pi 4 NixOS

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };
}
