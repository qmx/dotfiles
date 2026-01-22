{
  config,
  username,
  homeDirectory,
  modelsLib,
  pkgs,
  ...
}:
let
  # Model lists - single source of truth
  localModels = [
    "SmolLM3-3B-Q4-64K-KVQ8"
    "SmolLM3-3B-Q8-128K-KVQ8"
    "Qwen3-Coder-30B-Q4-128K-KVQ8"
    "Qwen3-VL-4B-Thinking-Q8-32K-KVQ8"
    "Devstral-Small-2-24B-2512-Q4-128K-KVQ8"
    "GLM-4.7-Flash-Q4-128K-KVQ8"
  ];
  orthancModels = [
    "SmolLM3-3B-Q8-128K"
    "SmolLM3-3B-Q4-64K-4x"
    "Gemma-3-12B-Q4-128K"
    "Gemma-3-27B-Q4-128K"
    "Llama-3.1-8B-Q8-128K"
    "Qwen3-Coder-30B-Q8-256K"
    "Qwen3-Coder-30B-Q8-200K-3x-KVQ8"
    "Qwen3-Coder-30B-Q6-128K-4x"
    "Qwen3-Coder-30B-Q4-256K"
    "Qwen3-Next-80B-Thinking-Q4-256K"
    "Qwen3-Next-80B-Instruct-Q8-256K"
    "Qwen3-30B-Instruct-2507-Q8-256K"
    "GPT-OSS-20B-Q8-128K"
    "GPT-OSS-120B-Q8-128K"
    "GLM-4.5-Air-Q4-128K"
    "GLM-4.7-Flash-Q4-200K-2x-KVQ8-rocm"
    "GLM-4.7-Flash-Q4-200K-2x-KVQ8-vulkan"
    "Devstral-Small-2-24B-2512-Q8-200K-KVQ8"
    "Qwen3-Coder-30B-Q8_0-200K-2x-KVQ8"
    "Qwen3-Coder-30B-Q5_K_XL-200K-2x-KVQ8"
    "Qwen3-Coder-30B-Q4-200K-2x-KVQ8"
  ];

  # Path to repo-relative files
  repoRoot = ../../..;
in
{
  imports = [ ../../../roles/dev/home-manager ];

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";

    # Finicky browser routing configuration
    file.".finicky.js".source = ../finicky.js;
  };

  # Secrets management with age + minijinja
  secrets = {
    enable = true;
    encrypted = "${repoRoot}/secrets/secrets.json.age";
    envFile = "${homeDirectory}/.secrets/env";
    templates = {
      env = {
        template = "${repoRoot}/templates/env.j2";
        output = "${homeDirectory}/.secrets/env";
      };
      opencode = {
        template = "${repoRoot}/templates/opencode.json.j2";
        output = "${homeDirectory}/.config/opencode/opencode.json";
        extraData = [ config.xdg.configFile."opencode/opencode-data.json".source ];
        mode = "0644";
      };
      claude-code-router = {
        template = "${repoRoot}/templates/claude-code-router.json.j2";
        output = "${homeDirectory}/.claude-code-router/config.json";
        extraData = [ config.xdg.configFile."claude-code-router/data.json".source ];
        mode = "0644";
      };
    };
  };

  # llama-swap with macOS models
  services.llama-swap = {
    enable = true;
    models = modelsLib.toLlamaSwapModels (modelsLib.selectModels localModels);

    # Keep whisper/kokoro running even when LLM models are loaded
    groups.always-on = {
      swap = false;
      exclusive = false;
      persistent = true;
    };

    # Whisper speech-to-text via proxy mode
    proxyModels.whisper = {
      package = pkgs.whisper-cpp;
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
        "--convert"
        "-mc"
        "500"
        "-ml"
        "2000"
        "-sow"
        "--vad"
      ];
      env = [ "PATH=${pkgs.ffmpeg}/bin" ];
    };

    # Kokoro text-to-speech via proxy mode
    proxyModels.kokoro = {
      package = pkgs.kokoro-fastapi;
      binary = "kokoro-server";
      port = 8880;
      checkEndpoint = "/health";
      useModelArg = false;
      group = "always-on";
      ttl = 120;
      aliases = [
        "tts"
        "kokoro-tts"
      ];
    };
  };

  # opencode providers (generates opencode-data.json, final config via secrets template)
  opencode = {
    providers = {
      local = localModels;
      orthanc = orthancModels;
    };
    providerNames.orthanc = "Orthanc Inference Server";
    defaultModel = "orthanc/Qwen3-Coder-30B-Q8_0-200K-2x-KVQ8";
    permission = {
      bash = {
        "git push" = "deny";
      };
    };
  };

  # claude-code-router - connects to orthanc inference server
  programs.claude-code-router = {
    enable = true;
    models = [
      "Qwen3-Coder-30B-Q8-200K-3x-KVQ8"
      "Qwen3-30B-Thinking-2507-Q8-256K"
    ];
    defaultModel = "Qwen3-Coder-30B-Q8-200K-3x-KVQ8";
    backgroundModel = "Qwen3-Coder-30B-Q8-200K-3x-KVQ8";
    thinkModel = "Qwen3-30B-Thinking-2507-Q8-256K";
  };
}
