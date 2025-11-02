{ config, pkgs, lib, ... }:

{
  # Create XDG directories
  home.file.".local/share/mymodels/.keep".text = "";
  home.file.".local/state/llama-swap/.keep".text = "";

  # Deploy llama-swap config with home directory and llama-server path substitution
  xdg.configFile."llama-swap/config.yml".text =
    builtins.replaceStrings
      ["\${HOME}" "llama-server"]
      [config.home.homeDirectory "${pkgs.llama-cpp}/bin/llama-server"]
      (builtins.readFile ./config.yml);

  # Set up launchd agent
  launchd.agents.llama-swap = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.llama-swap}/bin/llama-swap"
        "-config"
        "${config.xdg.configHome}/llama-swap/config.yml"
        "--watch-config"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/.local/state/llama-swap/stdout.log";
      StandardErrorPath = "${config.home.homeDirectory}/.local/state/llama-swap/stderr.log";
    };
  };
}
