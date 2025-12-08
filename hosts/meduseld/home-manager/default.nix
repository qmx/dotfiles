{
  username,
  homeDirectory,
  llamaLib,
  secrets,
  ...
}:
let
  # Model lists - single source of truth
  localModels = [
    "SmolLM3-3B-Q4"
    "SmolLM3-3B-Q8"
    "SmolLM3-3B-32K"
    "Gemma-3-12B"
    "Llama-3.1-8B"
  ];
  orthancModels = [
    "SmolLM3-3B-Q8"
    "Gemma-3-12B"
    "Gemma-3-27B"
    "Llama-3.1-8B"
    "Qwen3-Coder-30B"
    "Qwen3-Coder-30B-Q4"
    "Qwen3-Next-80B"
    "Qwen3-Next-80B-Instruct"
    "Qwen3-30B-2507"
    "GPT-OSS-20B"
    "GPT-OSS-120B"
    "GLM-4.5-Air"
  ];
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
    models = llamaLib.toLlamaSwapModels (llamaLib.selectModels localModels);
  };

  # opencode providers
  programs.opencode = {
    providers = {
      local = localModels;
      orthanc = orthancModels;
    };
    providerUrls.orthanc = secrets.orthancUrl or "http://localhost:8080";
    providerNames.orthanc = "Orthanc Inference Server";
    defaultModel = "orthanc/Qwen3-Coder-30B";
    smallModel = "local/SmolLM3-3B-32K";
  };
}
