# Library functions for llama model configuration
{ lib }:

let
  # Import the model catalog
  models = import ./llama-models.nix;

  # Select models from catalog by name list
  # selectModels [ "SmolLM3-3B-Q8" "Gemma-3-12B" ] => subset of catalog
  selectModels = names:
    lib.filterAttrs (name: _: lib.elem name names) models;

  # Convert catalog model to llama-swap format
  # Removes opencode-specific fields
  toLlamaSwapModel = model: {
    inherit (model) hf ctxSize flashAttn aliases extraArgs;
  };

  # Convert catalog models to llama-swap format
  toLlamaSwapModels = catalog:
    lib.mapAttrs (_: toLlamaSwapModel) catalog;

  # Convert catalog model to opencode format
  toOpencodeModel = model: {
    name = model.displayName;
    reasoning = model.reasoning;
    tool_call = model.toolCall;
    limit = {
      context = model.ctxSize;
      output = model.outputLimit;
    };
  };

  # Convert catalog models to opencode format
  toOpencodeModels = catalog:
    lib.mapAttrs (_: toOpencodeModel) catalog;

in {
  inherit models selectModels toLlamaSwapModels toOpencodeModels;
}
