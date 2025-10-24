{ username, homeDirectory, ... }:
{
  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";
  };
}
