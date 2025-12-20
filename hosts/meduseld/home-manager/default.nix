{
  config,
  username,
  homeDirectory,
  modelsLib,
  ...
}:
let
  # Model lists - single source of truth
  localModels = [
    "SmolLM3-3B-Q4"
    "SmolLM3-3B-Q8"
    "SmolLM3-3B-32K"
    "SmolLM3-3B-32K-2x"
    "SmolLM3-3B-128K-4x"
    "Gemma-3-12B"
    "Llama-3.1-8B"
  ];
  orthancModels = [
    "SmolLM3-3B-Q8"
    "SmolLM3-3B-128K-4x"
    "Gemma-3-12B"
    "Gemma-3-27B"
    "Llama-3.1-8B"
    "Qwen3-Coder-30B"
    "Qwen3-Coder-30B-Q6-4x"
    "Qwen3-Coder-30B-Q4"
    "Qwen3-Next-80B-Thinking"
    "Qwen3-Next-80B-Instruct"
    "Qwen3-30B-Instruct-2507"
    "GPT-OSS-20B"
    "GPT-OSS-120B"
    "GLM-4.5-Air"
  ];

  # Path to repo-relative files
  repoRoot = ../../..;
in
{
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
  };

  # opencode providers (generates opencode-data.json, final config via secrets template)
  programs.opencode = {
    providers = {
      local = localModels;
      orthanc = orthancModels;
    };
    providerNames.orthanc = "Orthanc Inference Server";
    defaultModel = "orthanc/Qwen3-Coder-30B-Q6-4x";
    smallModel = "local/SmolLM3-3B-128K-4x";
  };

  # claude-code-router - connects to orthanc inference server
  programs.claude-code-router = {
    enable = true;
    models = [ "Qwen3-Coder-30B" "qwen3-coder" "qwen3-30b" "Qwen3-30B-Thinking" ];
    defaultModel = "Qwen3-Coder-30B";
    backgroundModel = "Qwen3-Coder-30B";
    thinkModel = "Qwen3-30B-Thinking";
  };
}
