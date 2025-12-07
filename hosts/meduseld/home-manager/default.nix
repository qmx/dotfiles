{
  username,
  homeDirectory,
  lib,
  llamaLib,
  secrets,
  ...
}:
let
  # Model lists - single source of truth
  localModels = [ "SmolLM3-3B-Q4" "SmolLM3-3B-Q8" "Gemma-3-12B" "Llama-3.1-8B" ];
  orthancModels = [
    "SmolLM3-3B-Q8" "Gemma-3-12B" "Gemma-3-27B" "Llama-3.1-8B"
    "Qwen3-Coder-30B" "Qwen3-Coder-30B-Q4" "Qwen3-Next-80B"
    "Qwen3-Next-80B-Instruct" "Qwen3-30B-2507" "GPT-OSS-20B"
    "GPT-OSS-120B" "GLM-4.5-Air"
  ];

  # Convert to llama-swap format with group overrides
  llamaSwapModels = llamaLib.toLlamaSwapModels (llamaLib.selectModels localModels);
  withGroups = lib.mapAttrs (name: model:
    if lib.elem name [ "SmolLM3-3B-Q4" "SmolLM3-3B-Q8" "Llama-3.1-8B" ]
    then model // { group = "small-models"; }
    else model
  ) llamaSwapModels;
in
{
  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";

    # Finicky browser routing configuration
    file.".finicky.js".source = ../finicky.js;
  };

  # llama-swap with macOS models
  services.llama-swap = {
    enable = true;
    groups.small-models = {
      swap = false;
      exclusive = false;
    };
    models = withGroups;
  };

  # opencode providers
  programs.opencode = {
    providers = {
      llama-swap = localModels;
      orthanc = orthancModels;
    };
    providerUrls.orthanc = secrets.orthancUrl or "http://localhost:8080";
    providerNames.orthanc = "Orthanc Inference Server";
    defaultModel = "orthanc/Qwen3-Next-80B";
    smallModel = "llama-swap/SmolLM3-3B-Q8";
  };
}
