{ username, homeDirectory, ... }:
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
    models = {
      "SmolLM3-3B-Q4" = {
        hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
        ctxSize = 131072;
        aliases = [ "smollm3" "smollm3-q4" ];
        group = "small-models";
        extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.95" ];
      };
      "SmolLM3-3B-Q8" = {
        hf = "unsloth/SmolLM3-3B-128K-GGUF:Q8_K_XL";
        ctxSize = 131072;
        aliases = [ "smollm3-q8" ];
        group = "small-models";
        extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.95" ];
      };
      "Gemma-3-12B" = {
        hf = "unsloth/gemma-3-12b-it-qat-int4-GGUF:Q4_K_XL";
        ctxSize = 131072;
        flashAttn = true;
        aliases = [ "gemma3" "gemma-12b" ];
        extraArgs = [ "--jinja" "-ngl 99" "--temp 1.0" "--top-k 64" "--top-p 0.95" "--min-p 0.0" ];
      };
    };
  };
}
