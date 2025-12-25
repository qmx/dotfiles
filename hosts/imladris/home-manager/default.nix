{
  username,
  homeDirectory,
  ...
}:

{
  # imladris - NixOS VM on Synology VMM

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };
}
