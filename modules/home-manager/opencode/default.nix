{
  config,
  lib,
  pkgs,
  modelsLib,
  ...
}:

let
  cfg = config.opencode;
  agentBrowserSkill = "${pkgs.agent-browser-skill}/share/opencode/skills/agent-browser";
  ralphTuiSkill = "${pkgs.ralph-tui-skill}/share/opencode/skills/ralph-tui-prd";

  # Build models attrset for a provider using lib's converter
  buildProviderModels = modelNames: modelsLib.toOpencodeModels (modelsLib.selectModels modelNames);

  # Default display names for providers
  defaultNames = {
    local = "Local Llama Swap";
  };

  # Get base URL for a provider
  getBaseUrl =
    name:
    if name == "orthanc" && cfg.orthancUrl != null then
      "${cfg.orthancUrl}/v1"
    else
      "http://localhost:8080/v1";

  # Build a single provider config with URL
  buildProvider = name: modelNames: {
    npm = "@ai-sdk/openai-compatible";
    name = cfg.providerNames.${name} or defaultNames.${name} or name;
    options = {
      baseURL = getBaseUrl name;
      apiKey = "dummy";
    };
    models = buildProviderModels modelNames;
  };

  # Generate complete opencode config
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    share = "disabled";
    provider = lib.mapAttrs buildProvider cfg.providers;
    model = cfg.defaultModel;
  }
  // lib.optionalAttrs (cfg.smallModel != null) {
    small_model = cfg.smallModel;
  }
  // lib.optionalAttrs (cfg.agentModels != { }) {
    agent = cfg.agentModels;
  }
  // lib.optionalAttrs (cfg.permission != { }) {
    permission = cfg.permission;
  }
  // {
    autoupdate = true;
    mcp = {
      ddg-search = {
        type = "local";
        command = [ "duckduckgo-mcp-server" ];
        enabled = true;
      };
      budgie = {
        type = "remote";
        url = "http://127.0.0.1:8787/mcp";
        enabled = false;
        timeout = 180000;
      };
    };
  };

  jsonFormat = pkgs.formats.json { };
  configFile = jsonFormat.generate "opencode.json" opencodeConfig;
in
{
  options.opencode = {
    orthancUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "URL for orthanc inference server (null = localhost)";
    };

    providers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      description = "Attrset of provider name to list of model names from catalog";
    };

    providerNames = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Attrset of provider name to display name";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "local/SmolLM3-3B-Q8";
      description = "Default model in provider/model format";
    };

    smallModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Small model for quick tasks";
    };

    agentModels = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            model = lib.mkOption {
              type = lib.types.str;
              description = "Model for this agent in provider/model format";
            };
            description = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Brief description of what the agent does";
            };
            mode = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  "primary"
                  "subagent"
                  "all"
                ]
              );
              default = null;
              description = "Agent type";
            };
            temperature = lib.mkOption {
              type = lib.types.nullOr lib.types.float;
              default = null;
              description = "Response randomness (0.0-1.0)";
            };
            steps = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "Maximum agentic iterations";
            };
            permission = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
              description = "Permission settings for tools (allow/deny/ask or pattern objects)";
            };
            prompt = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "System prompt for custom agents (creates markdown file)";
            };
          };
        }
      );
      default = { };
      description = "Per-agent config (plan, build, research, general, explore, title, summary, compaction)";
    };

    permission = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Permission settings for tools (edit, bash, skill, webfetch, doom_loop, external_directory)";
      example = {
        bash = {
          "git push" = "deny";
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.providers != { }) {
      # Disable nixpkgs opencode from core.nix - we use the flake version instead
      programs.opencode.enable = lib.mkForce false;

      # Deploy complete opencode.json config
      xdg.configFile."opencode/opencode.json".source = configFile;
    })
    {
      home.packages = [ pkgs.agent-browser ];
      xdg.configFile."opencode/skills/agent-browser" = {
        source = agentBrowserSkill;
        recursive = true;
      };
      xdg.configFile."opencode/skills/ralph-tui-prd" = {
        source = ralphTuiSkill;
        recursive = true;
      };
    }
  ];
}
