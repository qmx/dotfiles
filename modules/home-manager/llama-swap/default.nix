{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.llama-swap;
  llamaServerPath = "${cfg.llamaCppPackage}/bin/llama-server";

  # Import ggufs catalog for pre-fetched models
  catalog = import ../../../lib/models.nix;

  # Fetch GGUF from HuggingFace with hash verification
  # Returns store path if in catalog, null otherwise (graceful fallback to -hf)
  fetchGGUF =
    hfId:
    let
      entry = catalog.ggufs.${hfId} or null;
      # Parse hfId: "org/repo-GGUF:quant" -> repo part for URL
      parts = builtins.match "([^:]+):(.+)" hfId;
      repo = builtins.elemAt parts 0;
      baseUrl = "https://huggingface.co/${repo}/resolve/main";
    in
    if entry == null then
      null
    else if entry ? file then
      # Single file
      pkgs.fetchurl {
        url = "${baseUrl}/${entry.file}";
        sha256 = entry.sha256;
        name = entry.file;
      }
    else if entry ? files then
      # Split files - create directory with symlinks
      pkgs.linkFarm "gguf-${builtins.replaceStrings [ "/" ":" ] [ "-" "-" ] hfId}" (
        map (f: {
          name = f.name;
          path = pkgs.fetchurl {
            url = "${baseUrl}/${f.name}";
            sha256 = f.sha256;
            name = f.name;
          };
        }) entry.files
      )
    else
      null;

  # Build command string for a proxy model (whisper, etc.)
  buildProxyCmd =
    name: model:
    let
      serverPath = "${model.package}/bin/${model.binary}";
      baseArgs = [
        serverPath
        "--host 127.0.0.1"
        "--port ${toString model.port}"
        "-m ${model.modelPath}"
      ];
      extraArgs = model.extraArgs;
    in
    lib.concatStringsSep " " (baseArgs ++ extraArgs);

  # Build proxy model config for YAML
  buildProxyModelConfig =
    name: model:
    {
      proxy = "http://127.0.0.1:${toString model.port}";
      checkEndpoint = model.checkEndpoint;
      cmd = buildProxyCmd name model;
    }
    // lib.optionalAttrs (model.ttl != null) {
      ttl = model.ttl;
    }
    // lib.optionalAttrs (model.aliases != [ ]) {
      aliases = model.aliases;
    }
    // lib.optionalAttrs (model.group != null) {
      group = model.group;
    }
    // lib.optionalAttrs (model.env != [ ]) {
      env = model.env;
    };

  # Build command string for a model
  buildCmd =
    name: model:
    let
      # Check if model is in ggufs catalog for pre-fetched path
      ggufPath = fetchGGUF model.hf;
      modelArg = if ggufPath != null then "-m ${ggufPath}" else "-hf ${model.hf}";
      baseArgs = [
        llamaServerPath
        "--port \${PORT}"
        modelArg
        "--ctx-size ${toString model.ctxSize}"
      ];
      flashAttnArg = lib.optional model.flashAttn "--flash-attn on";
      metricsArg = lib.optional cfg.enableMetrics "--metrics";
      # Draft model args for speculative decoding
      draftArgs =
        if model.draftModel != null then
          let
            dc = model.draftConfig;
            # Check if draft model is in ggufs catalog
            draftPath = fetchGGUF model.draftModel;
            draftModelArg =
              if draftPath != null then
                [
                  "-mrd"
                  "${draftPath}"
                ]
              else
                [
                  "-hfrd"
                  model.draftModel
                ];
          in
          draftModelArg
          ++ [
            "-ngld"
            (toString dc.gpuLayers)
            "--draft-max"
            (toString dc.maxTokens)
            "--draft-min"
            (toString dc.minTokens)
          ]
          ++ lib.optionals (dc.pMin != null) [
            "--draft-p-min"
            (toString dc.pMin)
          ]
        else
          [ ];
      extraArgs = model.extraArgs;
    in
    lib.concatStringsSep " " (baseArgs ++ flashAttnArg ++ metricsArg ++ draftArgs ++ extraArgs);

  # Build model config for YAML
  buildModelConfig =
    name: model:
    {
      cmd = buildCmd name model;
      ttl = model.ttl;
    }
    // lib.optionalAttrs (model.aliases != [ ]) {
      aliases = model.aliases;
    }
    // lib.optionalAttrs (model.group != null) {
      group = model.group;
    };

  # Get proxyModels that belong to each group
  proxyModelsByGroup =
    let
      proxyWithGroup = lib.filterAttrs (_: m: m.group != null) cfg.proxyModels;
    in
    lib.foldlAttrs (
      acc: name: model:
      acc // { ${model.group} = (acc.${model.group} or [ ]) ++ [ name ]; }
    ) { } proxyWithGroup;

  # Build group config for YAML
  buildGroupConfig =
    name: group:
    let
      # Merge explicit members with proxyModels that have this group
      allMembers = group.members ++ (proxyModelsByGroup.${name} or [ ]);
    in
    {
      swap = group.swap;
      exclusive = group.exclusive;
    }
    // lib.optionalAttrs group.persistent {
      persistent = true;
    }
    // lib.optionalAttrs (allMembers != [ ]) {
      members = allMembers;
    };

  # Generate full config
  llmModels = lib.mapAttrs buildModelConfig cfg.models;
  proxyModels = lib.mapAttrs buildProxyModelConfig cfg.proxyModels;
  allModels = llmModels // proxyModels;

  generatedConfig = {
    healthCheckTimeout = cfg.healthCheckTimeout;
    models = allModels;
  }
  // lib.optionalAttrs (cfg.groups != { }) {
    groups = lib.mapAttrs buildGroupConfig cfg.groups;
  };

  yamlFormat = pkgs.formats.yaml { };
  configFile = yamlFormat.generate "llama-swap-config.yml" generatedConfig;
in
{
  options.services.llama-swap = {
    enable = lib.mkEnableOption "llama-swap LLM model management proxy";

    llamaCppPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llama-cpp;
      defaultText = lib.literalExpression "pkgs.llama-cpp";
      description = "The llama.cpp package to use (e.g., pkgs.llama-cpp-rocm for ROCm support).";
    };

    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/share/llama-models";
      description = "Directory for llama.cpp model cache (LLAMA_CACHE env var).";
    };

    healthCheckTimeout = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Seconds to wait for model to load/download and become ready (startup timeout).";
    };

    enableMetrics = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Prometheus metrics on llama-server (accessible via /upstream/<model>/metrics).";
    };

    models = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            hf = lib.mkOption {
              type = lib.types.str;
              description = "HuggingFace repo and quantization (e.g., 'unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL').";
            };
            ctxSize = lib.mkOption {
              type = lib.types.int;
              default = 8192;
              description = "Context size for the model.";
            };
            ttl = lib.mkOption {
              type = lib.types.int;
              default = 300;
              description = "Time-to-live in seconds before unloading idle model.";
            };
            flashAttn = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable flash attention.";
            };
            aliases = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Alternative names for this model.";
            };
            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional command-line arguments for llama-server.";
            };
            group = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Group name for this model.";
            };
            draftModel = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "HuggingFace repo for draft model in speculative decoding (e.g., 'unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL').";
            };
            draftConfig = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  gpuLayers = lib.mkOption {
                    type = lib.types.int;
                    default = 99;
                    description = "GPU layers for draft model (-ngld).";
                  };
                  maxTokens = lib.mkOption {
                    type = lib.types.int;
                    default = 16;
                    description = "Maximum tokens to draft (--draft-max).";
                  };
                  minTokens = lib.mkOption {
                    type = lib.types.int;
                    default = 1;
                    description = "Minimum tokens to draft (--draft-min).";
                  };
                  pMin = lib.mkOption {
                    type = lib.types.nullOr lib.types.float;
                    default = null;
                    description = "Minimum probability threshold (--draft-p-min).";
                  };
                };
              };
              default = { };
              description = "Speculative decoding parameters when draftModel is set.";
            };
          };
        }
      );
      default = { };
      description = "Models to configure for llama-swap.";
    };

    groups = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            swap = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to swap models in this group.";
            };
            exclusive = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether this group is exclusive (unloads other groups).";
            };
            persistent = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Prevents other groups from unloading models in this group.";
            };
            members = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Model names that belong to this group.";
            };
          };
        }
      );
      default = { };
      description = "Model groups for llama-swap.";
    };

    proxyModels = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            package = lib.mkOption {
              type = lib.types.package;
              description = "Package providing the server binary (e.g., pkgs.whisper-cpp-vulkan).";
            };
            binary = lib.mkOption {
              type = lib.types.str;
              default = "whisper-server";
              description = "Binary name within the package.";
            };
            port = lib.mkOption {
              type = lib.types.int;
              description = "Port for the proxy server to listen on.";
            };
            checkEndpoint = lib.mkOption {
              type = lib.types.str;
              description = "Health check endpoint path (e.g., '/v1/audio/transcriptions/').";
            };
            modelPath = lib.mkOption {
              type = lib.types.str;
              description = "Path to the model file.";
            };
            ttl = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "Time-to-live in seconds before unloading idle model.";
            };
            aliases = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Alternative names for this model.";
            };
            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional command-line arguments for the server.";
            };
            group = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Group name for this model.";
            };
            env = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Environment variables for the server process (e.g., PATH=...).";
            };
          };
        }
      );
      default = { };
      description = "Proxy-based models (whisper, etc.) that use a separate server process.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create cache directory
    home.file."${cfg.cacheDir}/.keep".text = "";
    home.file.".local/state/llama-swap/.keep".text = "";

    # Deploy generated config
    xdg.configFile."llama-swap/config.yml".source = configFile;

    # macOS: launchd agent
    launchd.agents.llama-swap = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.llama-swap}/bin/llama-swap"
          "-config"
          "${config.xdg.configHome}/llama-swap/config.yml"
          "--watch-config"
        ];
        EnvironmentVariables = {
          LLAMA_CACHE = cfg.cacheDir;
        };
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/.local/state/llama-swap/stdout.log";
        StandardErrorPath = "${config.home.homeDirectory}/.local/state/llama-swap/stderr.log";
      };
    };

    # Linux: systemd user service
    systemd.user.services.llama-swap = lib.mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "llama-swap LLM model management proxy";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        Environment = [ "LLAMA_CACHE=${cfg.cacheDir}" ];
        ExecStart = "${pkgs.llama-swap}/bin/llama-swap -config ${config.xdg.configHome}/llama-swap/config.yml --watch-config";
        Restart = "always";
        RestartSec = 3;
        StandardOutput = "append:${config.home.homeDirectory}/.local/state/llama-swap/stdout.log";
        StandardError = "append:${config.home.homeDirectory}/.local/state/llama-swap/stderr.log";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
