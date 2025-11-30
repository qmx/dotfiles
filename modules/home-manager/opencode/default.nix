{ config, lib, ... }:

let
  secretsPath = "${config.home.homeDirectory}/.config/nix/secrets.json";
  tryReadSecrets = builtins.tryEval (builtins.fromJSON (builtins.readFile secretsPath));
  secrets = if tryReadSecrets.success then tryReadSecrets.value else { braveApiKey = ""; };
in
{
  # Disable nixpkgs opencode from core.nix - we use the flake version instead
  programs.opencode.enable = lib.mkForce false;

  # Deploy opencode configuration
  xdg.configFile."opencode/opencode.json".source = ./opencode.json;

  # Set BRAVE_API_KEY from secrets
  programs.zsh.sessionVariables.BRAVE_API_KEY = secrets.braveApiKey;
}
