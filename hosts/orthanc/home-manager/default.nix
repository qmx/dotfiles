{
  config,
  username,
  homeDirectory,
  pkgs,
  lib,
  llamaLib,
  ...
}:
let
  # Model list - single source of truth
  localModels = [
    "SmolLM3-3B-Q8"
    "SmolLM3-3B-32K"
    "Gemma-3-12B"
    "Gemma-3-27B"
    "Llama-3.1-8B"
    "Qwen3-Coder-30B"
    "Qwen3-Coder-30B-Q4"
    "Qwen3-Next-80B-Thinking"
    "Qwen3-Next-80B-Instruct"
    "Qwen3-30B-Instruct-2507"
    "Qwen3-30B-Thinking"
    "Qwen3-4B-Thinking"
    "GPT-OSS-20B"
    "GPT-OSS-120B"
    "GLM-4.5-Air"
  ];

  # Convert to llama-swap format
  llamaSwapModels = llamaLib.toLlamaSwapModels (llamaLib.selectModels localModels);

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
    };
  };

  # llama-swap with ROCm models
  services.llama-swap = {
    enable = true;
    llamaCppPackage = pkgs.llama-cpp-rocm;
    groups = llamaLib.buildGroups llamaSwapModels;
    models = llamaSwapModels;
  };

  # opencode providers - just local llama-swap
  programs.opencode = {
    providers.local = localModels;
    defaultModel = "local/Qwen3-Coder-30B";
    smallModel = "local/SmolLM3-3B-32K";
  };
}
