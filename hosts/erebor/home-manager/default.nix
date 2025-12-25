{
  username,
  homeDirectory,
  ...
}:

{
  # erebor - Attic binary cache VM

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };
}
