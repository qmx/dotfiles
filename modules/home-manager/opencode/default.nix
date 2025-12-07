{ config, lib, pkgs, llamaLib, secrets ? {}, ... }:

let
  cfg = config.programs.opencode;

  # Convert a model name to opencode format using catalog
  toOpencodeModel = name:
    let model = llamaLib.models.${name}; in {
      name = model.displayName;
      reasoning = model.reasoning;
      tool_call = model.toolCall;
      limit = {
        context = model.ctxSize;
        output = model.outputLimit;
      };
    };

  # Build models attrset for a provider
  buildProviderModels = modelNames:
    lib.listToAttrs (map (name: {
      inherit name;
      value = toOpencodeModel name;
    }) modelNames);

  # Default URLs for known providers
  defaultUrls = {
    llama-swap = "http://localhost:8080";
  };

  # Default display names for providers
  defaultNames = {
    llama-swap = "Local Llama Swap";
  };

  # Build a single provider config
  buildProvider = name: modelNames: {
    npm = "@ai-sdk/openai-compatible";
    name = cfg.providerNames.${name} or defaultNames.${name} or name;
    options = {
      baseURL = "${cfg.providerUrls.${name} or defaultUrls.${name} or "http://localhost:8080"}/v1";
      apiKey = "dummy";
    };
    models = buildProviderModels modelNames;
  };

  # Generate full opencode config
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    provider = lib.mapAttrs buildProvider cfg.providers;
    model = cfg.defaultModel;
    small_model = cfg.smallModel;
    autoupdate = true;
    mcp = {
      brave-search = {
        type = "local";
        command = [ "npx" "-y" "@modelcontextprotocol/server-brave-search" ];
        enabled = true;
        environment = {
          BRAVE_API_KEY = "\${BRAVE_API_KEY}";
        };
      };
    };
  };

  jsonFormat = pkgs.formats.json { };
  configFile = jsonFormat.generate "opencode.json" opencodeConfig;
in
{
  options.programs.opencode = {
    providers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = {};
      description = "Attrset of provider name to list of model names from catalog";
    };

    providerUrls = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Attrset of provider name to base URL (without /v1)";
    };

    providerNames = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Attrset of provider name to display name";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "llama-swap/SmolLM3-3B-Q8";
      description = "Default model in provider/model format";
    };

    smallModel = lib.mkOption {
      type = lib.types.str;
      default = "llama-swap/SmolLM3-3B-Q8";
      description = "Small model for quick tasks";
    };
  };

  config = lib.mkIf (cfg.providers != {}) {
    # Disable nixpkgs opencode from core.nix - we use the flake version instead
    programs.opencode.enable = lib.mkForce false;

    # Deploy generated opencode configuration
    xdg.configFile."opencode/opencode.json".source = configFile;

    # Set BRAVE_API_KEY from secrets
    programs.zsh.sessionVariables.BRAVE_API_KEY = secrets.braveApiKey or "";
  };
}
