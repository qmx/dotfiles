# Model catalog for llama-swap and opencode
# Each model includes both llama-swap config and opencode metadata
{
  "SmolLM3-3B-Q4" = {
    hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
    ctxSize = 131072;
    flashAttn = false;
    aliases = [ "smollm3" "smollm3-q4" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.95" ];
    # opencode metadata
    displayName = "SmolLM3 3B Q4";
    reasoning = true;
    toolCall = true;
    outputLimit = 32768;
  };

  "SmolLM3-3B-Q8" = {
    hf = "unsloth/SmolLM3-3B-128K-GGUF:Q8_K_XL";
    ctxSize = 131072;
    flashAttn = false;
    aliases = [ "smollm3-q8" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.95" ];
    # opencode metadata
    displayName = "SmolLM3 3B Q8";
    reasoning = true;
    toolCall = true;
    outputLimit = 32768;
  };

  "Gemma-3-12B" = {
    hf = "unsloth/gemma-3-12b-it-qat-int4-GGUF:Q4_K_XL";
    ctxSize = 131072;
    flashAttn = true;
    aliases = [ "gemma3" "gemma-12b" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 1.0" "--top-k 64" "--top-p 0.95" "--min-p 0.0" ];
    # opencode metadata
    displayName = "Gemma 3 12B";
    reasoning = false;
    toolCall = true;
    outputLimit = 8192;
  };

  "Gemma-3-27B" = {
    hf = "unsloth/gemma-3-27b-it-GGUF:Q4_K_XL";
    ctxSize = 131072;
    flashAttn = true;
    aliases = [ "gemma-27b" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 1.0" "--top-k 64" "--top-p 0.95" "--min-p 0.0" ];
    # opencode metadata
    displayName = "Gemma 3 27B";
    reasoning = false;
    toolCall = true;
    outputLimit = 8192;
  };

  "Llama-3.1-8B" = {
    hf = "unsloth/Llama-3.1-8B-Instruct-GGUF:Q8_K_XL";
    ctxSize = 131072;
    flashAttn = false;
    aliases = [ "llama-8b" "llama-3.1" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.9" "--top-k 40" "--repeat-penalty 1.1" ];
    # opencode metadata
    displayName = "Llama 3.1 8B";
    reasoning = false;
    toolCall = true;
    outputLimit = 8192;
  };

  "Qwen3-Coder-30B" = {
    hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
    ctxSize = 262144;
    flashAttn = false;
    aliases = [ "qwen3-coder" "qwen3-30b" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.7" "--top-p 0.8" "--top-k 20" "--repeat-penalty 1.05" ];
    # opencode metadata
    displayName = "Qwen3 Coder 30B Q8";
    reasoning = false;
    toolCall = true;
    outputLimit = 65536;
  };

  "Qwen3-Coder-30B-Q4" = {
    hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
    ctxSize = 262144;
    flashAttn = false;
    aliases = [ "qwen3-coder-q4" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.7" "--top-p 0.8" "--top-k 20" "--repeat-penalty 1.05" ];
    # opencode metadata
    displayName = "Qwen3 Coder 30B Q4";
    reasoning = false;
    toolCall = true;
    outputLimit = 65536;
  };

  "Qwen3-Next-80B" = {
    hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q4_K_XL";
    ctxSize = 262144;
    flashAttn = false;
    aliases = [ "qwen3-80b" "qwen3-thinking" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.95" "--top-k 20" ];
    # opencode metadata
    displayName = "Qwen3 Next 80B Thinking";
    reasoning = true;
    toolCall = true;
    outputLimit = 32768;
  };

  "Qwen3-Next-80B-Instruct" = {
    hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q8_K_XL";
    ctxSize = 262144;
    flashAttn = false;
    aliases = [ "qwen3-80b-instruct" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.7" "--top-p 0.8" "--top-k 20" "--repeat-penalty 1.05" ];
    # opencode metadata
    displayName = "Qwen3 Next 80B Instruct";
    reasoning = false;
    toolCall = true;
    outputLimit = 16384;
  };

  "Qwen3-30B-2507" = {
    hf = "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q8_K_XL";
    ctxSize = 262144;
    flashAttn = false;
    aliases = [ "qwen3-30b-2507" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.7" "--top-p 0.8" "--top-k 20" "--repeat-penalty 1.05" ];
    # opencode metadata
    displayName = "Qwen3 30B 2507";
    reasoning = false;
    toolCall = true;
    outputLimit = 16384;
  };

  "Qwen3-30B-Thinking" = {
    hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q8_K_XL";
    ctxSize = 262144;
    flashAttn = false;
    aliases = [ "qwen3-30b-thinking" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.95" "--top-k 20" ];
    # opencode metadata
    displayName = "Qwen3 30B Thinking";
    reasoning = true;
    toolCall = true;
    outputLimit = 32768;
    # speculative decoding
    draftModel = "unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL";
    draftConfig = {
      gpuLayers = 99;
      maxTokens = 16;
      minTokens = 1;
      pMin = 0.8;
    };
  };

  "Qwen3-4B-Thinking" = {
    hf = "unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL";
    ctxSize = 262144;
    flashAttn = false;
    aliases = [ "qwen3-4b-thinking" ];
    extraArgs = [ "--jinja" "-ngl 99" "--temp 0.6" "--top-p 0.95" "--top-k 20" ];
    # opencode metadata
    displayName = "Qwen3 4B Thinking";
    reasoning = true;
    toolCall = true;
    outputLimit = 32768;
  };

  "GPT-OSS-20B" = {
    hf = "unsloth/gpt-oss-20b-GGUF:Q8_K_XL";
    ctxSize = 131072;
    flashAttn = true;
    aliases = [ "gpt-oss" ];
    extraArgs = [ "--jinja" "-ngl 99" ];
    # opencode metadata
    displayName = "GPT-OSS 20B";
    reasoning = false;
    toolCall = true;
    outputLimit = 131072;
  };

  "GPT-OSS-120B" = {
    hf = "unsloth/gpt-oss-120b-GGUF:Q8_K_XL";
    ctxSize = 131072;
    flashAttn = false;
    aliases = [ "gpt-oss-120b" ];
    extraArgs = [ "--jinja" "-ngl 99" ];
    # opencode metadata
    displayName = "GPT-OSS 120B";
    reasoning = false;
    toolCall = true;
    outputLimit = 131072;
  };

  "GLM-4.5-Air" = {
    hf = "unsloth/GLM-4.5-Air-GGUF:Q4_K_M";
    ctxSize = 131072;
    flashAttn = false;
    aliases = [ "glm4" "glm-4.5" ];
    extraArgs = [ "--jinja" "-ngl 99" ];
    # opencode metadata
    displayName = "GLM-4.5 Air";
    reasoning = false;
    toolCall = true;
    outputLimit = 98304;
  };
}
