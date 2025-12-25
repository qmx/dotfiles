{ username, homeDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };
}
