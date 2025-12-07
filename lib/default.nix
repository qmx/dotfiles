# Library functions for llama model configuration
{ lib }:

let
  # Import the model catalog
  catalog = import ./llama-models.nix;
  models = catalog.models;
  groupConfigs = catalog.groupConfigs or {};

  # Select models from catalog by name list
  # selectModels [ "SmolLM3-3B-Q8" "Gemma-3-12B" ] => subset of catalog
  selectModels = names:
    lib.filterAttrs (name: _: lib.elem name names) models;

  # Convert catalog model to llama-swap format
  # Removes opencode-specific fields
  toLlamaSwapModel = model: {
    inherit (model) hf ctxSize flashAttn aliases extraArgs;
  } // lib.optionalAttrs (model ? group) {
    inherit (model) group;
  } // lib.optionalAttrs (model ? draftModel) {
    inherit (model) draftModel;
  } // lib.optionalAttrs (model ? draftConfig) {
    inherit (model) draftConfig;
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

  # Build llama-swap groups config from selected models
  # Derives `members` list from models that have matching `group` field
  buildGroups = selectedModels:
    let
      # Get unique groups used by selected models
      usedGroups = lib.unique (lib.filter (g: g != null)
        (lib.mapAttrsToList (_: m: m.group or null) selectedModels));

      # For each group, find its members and merge with groupConfig
      mkGroup = groupName:
        let
          members = lib.attrNames (lib.filterAttrs
            (_: m: (m.group or null) == groupName) selectedModels);
          cfg = groupConfigs.${groupName} or { swap = true; exclusive = true; };
        in cfg // { inherit members; };
    in lib.genAttrs usedGroups mkGroup;

in {
  inherit models groupConfigs selectModels toLlamaSwapModels toOpencodeModels buildGroups;
}
