{
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
    "SmolLM3-3B-Q8" "Gemma-3-12B" "Gemma-3-27B" "Llama-3.1-8B"
    "Qwen3-Coder-30B" "Qwen3-Coder-30B-Q4" "Qwen3-Next-80B"
    "Qwen3-Next-80B-Instruct" "Qwen3-30B-2507" "Qwen3-30B-Thinking"
    "Qwen3-4B-Thinking" "GPT-OSS-20B" "GPT-OSS-120B" "GLM-4.5-Air"
  ];

  # Convert to llama-swap format
  llamaSwapModels = llamaLib.toLlamaSwapModels (llamaLib.selectModels localModels);
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
    defaultModel = "local/Qwen3-Next-80B";
    smallModel = "local/SmolLM3-3B-Q8";
  };
}
