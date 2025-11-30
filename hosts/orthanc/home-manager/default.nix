{
  username,
  homeDirectory,
  pkgs,
  ...
}:

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
    models = {
      "SmolLM3-3B-Q8" = {
        hf = "unsloth/SmolLM3-3B-128K-GGUF:Q8_K_XL";
        ctxSize = 131072;
        aliases = [
          "smollm3"
          "smollm3-q8"
        ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 0.6"
          "--top-p 0.95"
        ];
      };
      "Qwen3-Coder-30B" = {
        hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
        ctxSize = 262144;
        aliases = [
          "qwen3-coder"
          "qwen3-30b"
        ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 0.7"
          "--top-p 0.8"
          "--top-k 20"
          "--repeat-penalty 1.05"
        ];
      };
      "Gemma-3-12B" = {
        hf = "unsloth/gemma-3-12b-it-qat-int4-GGUF:Q4_K_XL";
        ctxSize = 131072;
        flashAttn = true;
        aliases = [
          "gemma3"
          "gemma-12b"
        ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 1.0"
          "--top-k 64"
          "--top-p 0.95"
          "--min-p 0.0"
        ];
      };
      "Gemma-3-27B" = {
        hf = "unsloth/gemma-3-27b-it-GGUF:Q4_K_XL";
        ctxSize = 131072;
        flashAttn = true;
        aliases = [ "gemma-27b" ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 1.0"
          "--top-k 64"
          "--top-p 0.95"
          "--min-p 0.0"
        ];
      };
      "GPT-OSS-20B" = {
        hf = "unsloth/gpt-oss-20b-GGUF:Q8_K_XL";
        ctxSize = 131072;
        flashAttn = true;
        aliases = [ "gpt-oss" ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
        ];
      };
      "Qwen3-Next-80B" = {
        hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q4_K_XL";
        ctxSize = 262144;
        aliases = [
          "qwen3-80b"
          "qwen3-thinking"
        ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 0.6"
          "--top-p 0.95"
          "--top-k 20"
        ];
      };
      "GLM-4.5-Air" = {
        hf = "unsloth/GLM-4.5-Air-GGUF:Q4_K_M";
        ctxSize = 131072;
        aliases = [
          "glm4"
          "glm-4.5"
        ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
        ];
      };
      "Qwen3-30B-2507" = {
        hf = "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q8_K_XL";
        ctxSize = 262144;
        aliases = [ "qwen3-30b-2507" ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 0.7"
          "--top-p 0.8"
          "--top-k 20"
          "--repeat-penalty 1.05"
        ];
      };
      "Qwen3-Coder-30B-Q4" = {
        hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
        ctxSize = 262144;
        aliases = [ "qwen3-coder-q4" ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 0.7"
          "--top-p 0.8"
          "--top-k 20"
          "--repeat-penalty 1.05"
        ];
      };
      "Qwen3-Next-80B-Instruct" = {
        hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q8_K_XL";
        ctxSize = 262144;
        aliases = [ "qwen3-80b-instruct" ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
          "--temp 0.7"
          "--top-p 0.8"
          "--top-k 20"
          "--repeat-penalty 1.05"
        ];
      };
      "GPT-OSS-120B" = {
        hf = "unsloth/gpt-oss-120b-GGUF:Q8_K_XL";
        ctxSize = 131072;
        aliases = [ "gpt-oss-120b" ];
        extraArgs = [
          "--jinja"
          "-ngl 99"
        ];
      };
    };
  };
}
