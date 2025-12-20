{
  config,
  username,
  homeDirectory,
  pkgs,
  lib,
  modelsLib,
  ...
}:
let
  # Model list - single source of truth
  localModels = [
    "SmolLM3-3B-Q8"
    "SmolLM3-3B-32K"
    "SmolLM3-3B-32K-2x"
    "Gemma-3-12B"
    "Gemma-3-27B"
    "Llama-3.1-8B"
    "Qwen3-Coder-30B"
    "Qwen3-Coder-30B-2x"
    "Qwen3-Coder-30B-Q4"
    "Qwen3-Coder-30B-Q4-2x"
    "Qwen3-Coder-30B-Q4-4x"
    "Qwen3-Next-80B-Thinking"
    "Qwen3-Next-80B-Instruct"
    "Qwen3-30B-Instruct-2507"
    "Qwen3-30B-Thinking"
    "Qwen3-4B-Thinking"
    "GPT-OSS-20B"
    "GPT-OSS-120B"
    "GLM-4.5-Air"
    "Nemotron-3-Nano-30B"
    "Nemotron-3-Nano-30B-Tools"
  ];

  # Convert to llama-swap format
  llamaSwapModels = modelsLib.toLlamaSwapModels (modelsLib.selectModels localModels);

  repoRoot = ../../..;
in
{
  imports = [
    ../../../roles/linux-yubikey/home-manager
  ];

  # Use ROCm-enabled btop on orthanc
  programs.btop.package = pkgs.btop-rocm;

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";
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

  # llama-swap with ROCm models
  services.llama-swap = {
    enable = true;
    llamaCppPackage = pkgs.llama-cpp-rocm;
    groups = modelsLib.buildGroups llamaSwapModels;
    models = llamaSwapModels;
  };

  # opencode providers - just local llama-swap
  programs.opencode = {
    providers.local = localModels;
    defaultModel = "local/Qwen3-Coder-30B";
    smallModel = "local/SmolLM3-3B-32K";
  };

  # claude-code-router - local llama-swap
  programs.claude-code-router = {
    enable = true;
    models = [ "Qwen3-Coder-30B" "qwen3-coder" "qwen3-30b" "Qwen3-30B-Thinking" ];
    defaultModel = "Qwen3-Coder-30B";
    backgroundModel = "Qwen3-Coder-30B";
    thinkModel = "Qwen3-30B-Thinking";
  };
}
