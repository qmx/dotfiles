{
  username,
  homeDirectory,
  lib,
  llamaLib,
  ...
}:
let
  models = llamaLib.toLlamaSwapModels (llamaLib.selectModels [
    "SmolLM3-3B-Q4"
    "SmolLM3-3B-Q8"
    "Gemma-3-12B"
    "Llama-3.1-8B"
  ]);
  # Add group assignments for small models
  withGroups = lib.mapAttrs (name: model:
    if lib.elem name [ "SmolLM3-3B-Q4" "SmolLM3-3B-Q8" "Llama-3.1-8B" ]
    then model // { group = "small-models"; }
    else model
  ) models;
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
}
