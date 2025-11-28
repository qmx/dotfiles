{ username, homeDirectory, ... }:
{
  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";

    # Finicky browser routing configuration
    file.".finicky.js".source = ../finicky.js;
  };

  # Enable llama-swap service
  services.llama-swap.enable = true;
}
