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
  # Returns { model = path; mmproj = path or null; } if in catalog, null otherwise
  fetchGGUF =
    hfId:
    let
      entry = catalog.ggufs.${hfId} or null;
      # Parse hfId: "org/repo-GGUF:quant" -> repo part for URL
      parts = builtins.match "([^:]+):(.+)" hfId;
      repo = builtins.elemAt parts 0;
      baseUrl = "https://huggingface.co/${repo}/resolve/main";
      # Fetch mmproj if present in entry
      fetchMmproj =
        if entry ? mmproj then
          pkgs.fetchurl {
            url = "${baseUrl}/${entry.mmproj.file}";
            sha256 = entry.mmproj.sha256;
            name = entry.mmproj.file;
          }
        else
          null;
    in
    if entry == null then
      null
    else if entry ? file then
      # Single file (possibly with mmproj for VL models)
      {
        model = pkgs.fetchurl {
          url = "${baseUrl}/${entry.file}";
          sha256 = entry.sha256;
          name = entry.file;
        };
        mmproj = fetchMmproj;
      }
    else if entry ? files then
      # Split files - create directory with symlinks
      # f.name may contain subfolder path like "UD-Q8_K_XL/model-00001.gguf"
      {
        model = pkgs.linkFarm "gguf-${builtins.replaceStrings [ "/" ":" ] [ "-" "-" ] hfId}" (
          map (f: {
            # Use basename for symlink name (linkFarm doesn't support subdirs)
            name = builtins.baseNameOf f.name;
            path = pkgs.fetchurl {
              url = "${baseUrl}/${f.name}";
              sha256 = f.sha256;
              # fetchurl name can't have slashes
              name = builtins.baseNameOf f.name;
            };
          }) entry.files
        );
        mmproj = fetchMmproj;
      }
    else
      null;

  # Build command string for a proxy model (whisper, etc.)
  buildProxyCmd =
    name: model:
    let
      serverPath = "${model.package}/bin/${model.binary}";
      # Resolve model path: hf takes precedence over modelPath
      # Only required if useModelArg is true
      resolvedModelPath =
        if !model.useModelArg then
          null
        else if model.hf != null then
          let
            fetched = fetchGGUF model.hf;
          in
          if fetched != null then
            "${fetched.model}"
          else
            throw "proxyModels.${name}: hf='${model.hf}' not found in ggufs catalog"
        else if model.modelPath != null then
          model.modelPath
        else
          throw "proxyModels.${name}: either hf or modelPath must be set (or set useModelArg = false)";
      baseArgs = [
        serverPath
        "--host 127.0.0.1"
        "--port ${toString model.port}"
      ]
      ++ lib.optionals (resolvedModelPath != null) [ "-m ${resolvedModelPath}" ];
      # VAD model support for whisper
      vadArgs =
        if model.vadModel != null then
          let
            vadGguf = fetchGGUF model.vadModel;
          in
          if vadGguf != null then
            [ "-vm ${vadGguf.model}" ]
          else
            throw "proxyModels.${name}: vadModel='${model.vadModel}' not found in ggufs catalog"
        else
          [ ];
      extraArgs = model.extraArgs;
    in
    lib.concatStringsSep " " (baseArgs ++ vadArgs ++ extraArgs);

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

  # Build command string for SD model
  buildSdCmd =
    name: model:
    let
      sdServerPath = "${cfg.sdPackage}/bin/sd-server";
      diffusion = fetchGGUF model.diffusionModel;
      vae = fetchGGUF model.vae;
      llmModel = if model.llm != null then fetchGGUF model.llm else null;
    in
    if diffusion == null then
      throw "sdModels.${name}: diffusionModel='${model.diffusionModel}' not found in ggufs catalog"
    else if vae == null then
      throw "sdModels.${name}: vae='${model.vae}' not found in ggufs catalog"
    else
      lib.concatStringsSep " " (
        [
          sdServerPath
          "--listen-port \${PORT}"
          "--diffusion-model ${diffusion.model}"
          "--vae ${vae.model}"
        ]
        ++ lib.optionals (llmModel != null) [ "--llm ${llmModel.model}" ]
        ++ lib.optional model.flashAttn "--diffusion-fa"
        ++ lib.optional model.vaeTiling "--vae-tiling"
        ++ lib.optional model.offloadToCpu "--offload-to-cpu"
        ++ model.extraArgs
      );

  # Build SD model config for YAML
  buildSdModelConfig =
    name: model:
    {
      proxy = "http://127.0.0.1:${toString model.port}";
      checkEndpoint = "/";
      cmd = buildSdCmd name model;
    }
    // lib.optionalAttrs (model.ttl != null) {
      ttl = model.ttl;
    }
    // lib.optionalAttrs (model.aliases != [ ]) {
      aliases = model.aliases;
    }
    // lib.optionalAttrs (model.group != null) {
      group = model.group;
    };

  # Build command string for a model
  buildCmd =
    name: model:
    let
      # Check if model is in ggufs catalog for pre-fetched path
      gguf = fetchGGUF model.hf;
      modelArg = if gguf != null then "-m ${gguf.model}" else "-hf ${model.hf}";
      # Add --mmproj for VL models with projection files
      mmprojArg =
        if gguf != null && gguf.mmproj != null then
          [
            "--mmproj"
            "${gguf.mmproj}"
          ]
        else
          [ ];
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
            draftGguf = fetchGGUF model.draftModel;
            draftModelArg =
              if draftGguf != null then
                [
                  "-mrd"
                  "${draftGguf.model}"
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
    lib.concatStringsSep " " (
      baseArgs ++ mmprojArg ++ flashAttnArg ++ metricsArg ++ draftArgs ++ extraArgs
    );

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
  sdModels = lib.mapAttrs buildSdModelConfig cfg.sdModels;
  allModels = llmModels // proxyModels // sdModels;

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

    watchConfig = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Watch config file for changes and reload automatically. Disable to prevent workload interruption.";
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
            hf = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "HuggingFace identifier (e.g., 'ggerganov/whisper.cpp:large-v3-turbo'). Fetches from Nix store via ggufs catalog.";
            };
            modelPath = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Path to the model file. Use hf instead for Nix store integration.";
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
            useModelArg = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to pass -m <model> argument to the server. Set to false for servers that don't use model arguments (e.g., kokoro-fastapi).";
            };
            vadModel = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "HuggingFace identifier for VAD model (e.g., 'ggml-org/whisper-vad:silero-v6.2.0'). Adds -vm flag for whisper-cpp.";
            };
          };
        }
      );
      default = { };
      description = "Proxy-based models (whisper, etc.) that use a separate server process.";
    };

    sdPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.stable-diffusion-cpp;
      defaultText = lib.literalExpression "pkgs.stable-diffusion-cpp";
      description = "The stable-diffusion.cpp package to use (e.g., pkgs.stable-diffusion-cpp-rocm for ROCm support).";
    };

    sdModels = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            diffusionModel = lib.mkOption {
              type = lib.types.str;
              description = "HuggingFace identifier for diffusion model GGUF (e.g., 'leejet/Z-Image-Turbo-GGUF:Q8_0').";
            };
            vae = lib.mkOption {
              type = lib.types.str;
              description = "HuggingFace identifier for VAE model (e.g., 'auroraintech/flux-vae:ae.safetensors').";
            };
            llm = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "HuggingFace identifier for LLM prompt enhancement (e.g., 'unsloth/Qwen3-4B-Instruct-2507-GGUF:Q8_K_XL').";
            };
            port = lib.mkOption {
              type = lib.types.int;
              description = "Port for sd-server to listen on.";
            };
            flashAttn = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable flash attention for diffusion (--diffusion-fa).";
            };
            vaeTiling = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable VAE tiling for reduced VRAM usage (--vae-tiling).";
            };
            offloadToCpu = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Offload weights to RAM to save VRAM (--offload-to-cpu).";
            };
            ttl = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = 300;
              description = "Time-to-live in seconds before unloading idle model.";
            };
            aliases = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Alternative names for this model.";
            };
            group = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Group name for this model.";
            };
            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional command-line arguments for sd-server.";
            };
          };
        }
      );
      default = { };
      description = "Stable Diffusion models managed by llama-swap via sd-server.";
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
        ]
        ++ lib.optionals cfg.watchConfig [ "--watch-config" ];
        EnvironmentVariables = {
          LLAMA_CACHE = cfg.cacheDir;
        };
        KeepAlive = true;
        RunAtLoad = true;
        # Set working directory for child processes (whisper-server needs this for temp files)
        WorkingDirectory = "${config.home.homeDirectory}/.local/state/llama-swap";
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
        ExecStart = "${pkgs.llama-swap}/bin/llama-swap -config ${config.xdg.configHome}/llama-swap/config.yml${lib.optionalString cfg.watchConfig " --watch-config"}";
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
