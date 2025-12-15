{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code-router;
  jsonFormat = pkgs.formats.json { };

  dataFile = jsonFormat.generate "claude-code-router-data.json" {
    data = {
      models = cfg.models;
      defaultModel = cfg.defaultModel;
      backgroundModel = cfg.backgroundModel;
      thinkModel = cfg.thinkModel;
    };
  };
in
{
  options.programs.claude-code-router = {
    enable = lib.mkEnableOption "claude-code-router configuration";

    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of model names available via llama-swap";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      description = "Model for default tasks";
    };

    backgroundModel = lib.mkOption {
      type = lib.types.str;
      description = "Model for background tasks";
    };

    thinkModel = lib.mkOption {
      type = lib.types.str;
      description = "Model for reasoning/think tasks";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code-router ];
    xdg.configFile."claude-code-router/data.json".source = dataFile;
  };
}
