{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code-router;
  jsonFormat = pkgs.formats.json { };

  apiBaseUrl =
    if cfg.orthancUrl != null then
      "${cfg.orthancUrl}/v1/chat/completions"
    else
      "http://localhost:8080/v1/chat/completions";

  configFile = jsonFormat.generate "claude-code-router-config.json" {
    LOG = false;
    Providers = [
      {
        name = "llama-swap";
        api_base_url = apiBaseUrl;
        api_key = "not-needed";
        models = cfg.models;
      }
    ];
    Router = {
      default = "llama-swap,${cfg.defaultModel}";
      background = "llama-swap,${cfg.backgroundModel}";
      think = "llama-swap,${cfg.thinkModel}";
    };
  };
in
{
  options.programs.claude-code-router = {
    enable = lib.mkEnableOption "claude-code-router configuration";

    orthancUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "URL for orthanc inference server (null = localhost)";
    };

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
    home.file.".claude-code-router/config.json".source = configFile;
  };
}
