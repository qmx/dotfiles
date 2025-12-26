{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

let
  cfg = config.programs.attic-client;
  repoRoot = ../../..;
in
{
  options.programs.attic-client = {
    enable = lib.mkEnableOption "Attic binary cache client";

    server = lib.mkOption {
      type = lib.types.str;
      default = "erebor";
      description = "Name of the Attic server";
    };

    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "http://erebor:8080";
      description = "URL of the Attic server";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.attic-client ];

    secrets.templates.attic-config = {
      template = "${repoRoot}/templates/attic-config.toml.j2";
      output = "${homeDirectory}/.config/attic/config.toml";
      mode = "0600";
    };
  };
}
