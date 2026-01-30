{
  config,
  username,
  homeDirectory,
  pkgs,
  pkgs-unstable,
  lib,
  modelsLib,
  sops-nix,
  ...
}:
let
  # Model list - single source of truth
  localModels = [
    "SmolLM3-3B-Q4-64K"
    "SmolLM3-3B-Q8-128K"
    "SmolLM3-3B-Q4-32K"
    "SmolLM3-3B-Q4-32K-2x"
    "SmolLM3-3B-Q4-64K-4x"
    "Gemma-3-12B-Q4-128K"
    "Gemma-3-27B-Q4-128K"
    "Llama-3.1-8B-Q8-128K"
    "Qwen3-Coder-30B-Q4-200K"
    "Qwen3-Coder-30B-Q5-200K"
    "Qwen3-Coder-30B-Q8-200K"
    "Qwen3-Next-80B-Thinking-Q4-200K"
    "Qwen3-Next-80B-Thinking-Q8-200K"
    "Qwen3-Next-80B-Instruct-Q4-200K"
    "Qwen3-Next-80B-Instruct-Q8-200K"
    "Qwen3-30B-Thinking-2507-Q4-200K"
    "Qwen3-30B-Thinking-2507-Q8-200K"
    "Qwen3-30B-Instruct-2507-Q4-200K"
    "Qwen3-30B-Instruct-2507-Q8-200K"
    "Qwen3-4B-Thinking-2507-Q8-200K"
    "GPT-OSS-20B-Q8-128K"
    "GPT-OSS-120B-Q8-128K"
    "GLM-4.7-Flash-Q4-200K"
    "GLM-4.7-Flash-Q5-200K"
    "GLM-4.7-Flash-Q8-200K"
    "Nemotron-3-Nano-30B-Q8-256K"
    "Nemotron-3-Nano-30B-Q8-256K-Tools"
    "Devstral-2-123B-2512-Q4-128K-KVQ8"
    "Devstral-Small-2-24B-2512-Q8-200K-KVQ8"
    "Qwen3-VL-30B-Thinking-Q8-200K"
    "Qwen3-VL-30B-Instruct-Q8-200K"
    "Qwen3-VL-32B-Instruct-Q8-200K"
    "Qwen3-VL-4B-Thinking-Q8-200K"
  ];

  # Convert to llama-swap format
  llamaSwapModels = modelsLib.toLlamaSwapModels (modelsLib.selectModels localModels);

  repoRoot = ../../..;
in
{
  imports = [
    ../../../roles/dev/home-manager
    sops-nix.homeManagerModules.sops
  ];

  # Use ROCm-enabled btop on orthanc
  programs.btop.package = pkgs.btop-rocm;

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";
  };

  # Secrets management - env file via age + minijinja
  secrets = {
    enable = true;
    encrypted = "${repoRoot}/secrets/secrets.json.age";
    envFile = "${homeDirectory}/.secrets/env";
    templates = {
      env = {
        template = "${repoRoot}/templates/env.j2";
        output = "${homeDirectory}/.secrets/env";
      };
    };
  };

  # SOPS for nix-cache signing key
  sops = {
    age.keyFile = "${homeDirectory}/.config/age/keys.txt";
    defaultSopsFile = "${repoRoot}/secrets/home-manager.yaml";
    secrets.nixCacheSecretKey = { };
    templates."nix-cache.sec" = {
      content = config.sops.placeholder.nixCacheSecretKey;
      path = "${homeDirectory}/.secrets/nix-cache.sec";
      mode = "0600";
    };
  };

  services.llama-swap = {
    enable = true;
    llamaCppPackage = pkgs.llama-cpp-rocm;
    groups = modelsLib.buildGroups llamaSwapModels;
    models = llamaSwapModels;

    # Whisper speech-to-text via proxy mode
    proxyModels.whisper = {
      package = pkgs.whisper-cpp-vulkan;
      binary = "whisper-server";
      port = 9233;
      checkEndpoint = "/v1/audio/transcriptions/";
      hf = "ggerganov/whisper.cpp:large-v3-turbo";
      vadModel = "ggml-org/whisper-vad:silero-v6.2.0";
      group = "always-on";
      ttl = 120;
      extraArgs = [
        "--request-path"
        "/v1/audio/transcriptions"
        "--inference-path"
        "''"
        "--convert" # auto-convert m4a/mp3/etc to WAV via ffmpeg
        "-mc"
        "500" # max context for longer audio
        "-ml"
        "2000" # max length
        "-sow" # split on word
        "--vad" # Voice Activity Detection - skip silence/music
      ];
      env = [ "PATH=${pkgs.ffmpeg}/bin" ];
    };

    # Kokoro text-to-speech via proxy mode
    proxyModels.kokoro = {
      package = pkgs.kokoro-fastapi;
      binary = "kokoro-server";
      port = 8880;
      checkEndpoint = "/health";
      useModelArg = false; # kokoro-fastapi bundles model internally
      group = "always-on";
      ttl = 120;
      aliases = [
        "tts"
        "kokoro-tts"
      ];
    };

    # Stable Diffusion image generation via sd-server
    sdPackage = pkgs-unstable.stable-diffusion-cpp-rocm;
    sdModels.z-image-turbo = {
      diffusionModel = "leejet/Z-Image-Turbo-GGUF:Q8_0";
      vae = "auroraintech/flux-vae:ae.safetensors";
      llm = "unsloth/Qwen3-4B-Instruct-2507-GGUF:Q8_K_XL";
      port = 9234;
      flashAttn = true;
      ttl = 300;
      aliases = [
        "sd"
        "image"
      ];
    };
  };

  # opencode providers - just local llama-swap
  opencode = {
    providers.local = localModels;
    defaultModel = "local/Qwen3-Coder-30B-Q4-200K";
    permission = {
      bash = {
        "git push" = "deny";
      };
    };
  };

  # claude-code-router - local llama-swap
  programs.claude-code-router = {
    enable = true;
    models = [
      "Qwen3-Coder-30B-Q4-200K"
      "Qwen3-30B-Thinking-2507-Q4-200K"
    ];
    defaultModel = "Qwen3-Coder-30B-Q4-200K";
    backgroundModel = "Qwen3-Coder-30B-Q4-200K";
    thinkModel = "Qwen3-30B-Thinking-2507-Q4-200K";
  };

  systemd.user.services.model-backup = {
    Unit.Description = "Backup LLM and Whisper models to NAS";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "model-backup" ''
        ${pkgs.rsync}/bin/rsync -aP \
          ${homeDirectory}/.local/share/llama-models/ \
          /mnt/backups/models/llm-models/
        ${pkgs.rsync}/bin/rsync -aP \
          ${homeDirectory}/.local/share/whisper-models/ \
          /mnt/backups/models/whisper-models/
      ''}";
    };
  };

  systemd.user.timers.model-backup = {
    Unit.Description = "Nightly model backup timer";
    Timer = {
      OnCalendar = "*-*-* 01:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
