# Model catalog for llama-swap and opencode
{
  # Group configurations - define behavior for model groups
  groupConfigs = {
    coding = {
      swap = false; # don't unload when loading another from this group
      exclusive = false; # allow multiple models loaded simultaneously
    };
  };

  models = {
    "SmolLM3-3B-Q4" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      aliases = [
        "smollm3"
        "smollm3-q4"
      ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q4";
        reasoning = true;
        toolCall = true;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-Q8" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      aliases = [ "smollm3-q8" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      group = "coding";
      opencode = {
        displayName = "SmolLM3 3B Q8";
        reasoning = true;
        toolCall = true;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-32K" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 32768;
      flashAttn = false;
      aliases = [ "smollm3-32k" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      group = "coding";
      opencode = {
        displayName = "SmolLM3 3B 32K";
        reasoning = true;
        toolCall = true;
        outputLimit = 32768;
      };
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
      opencode = {
        displayName = "Gemma 3 12B";
        reasoning = false;
        toolCall = true;
        outputLimit = 8192;
      };
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
      opencode = {
        displayName = "Gemma 3 27B";
        reasoning = false;
        toolCall = true;
        outputLimit = 8192;
      };
    };

    "Llama-3.1-8B" = {
      hf = "unsloth/Llama-3.1-8B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      aliases = [
        "llama-8b"
        "llama-3.1"
      ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.9"
        "--top-k 40"
        "--repeat-penalty 1.1"
      ];
      opencode = {
        displayName = "Llama 3.1 8B";
        reasoning = false;
        toolCall = true;
        outputLimit = 8192;
      };
    };

    "Qwen3-Coder-30B" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
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
      group = "coding";
      opencode = {
        displayName = "Qwen3 Coder 30B Q8";
        reasoning = false;
        toolCall = true;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q4" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [ "qwen3-coder-q4" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q4";
        reasoning = false;
        toolCall = true;
        outputLimit = 65536;
      };
    };

    "Qwen3-Next-80B-Thinking" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q4_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [
        "qwen3-80b-thinking"
        "qwen3-thinking"
      ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Thinking";
        reasoning = true;
        toolCall = true;
        outputLimit = 32768;
      };
    };

    "Qwen3-Next-80B-Instruct" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [ "qwen3-80b-instruct" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Instruct";
        reasoning = false;
        toolCall = true;
        outputLimit = 16384;
      };
    };

    "Qwen3-30B-Instruct-2507" = {
      hf = "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [ "qwen3-30b-instruct-2507" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 30B Instruct 2507";
        reasoning = false;
        toolCall = true;
        outputLimit = 16384;
      };
    };

    "Qwen3-30B-Thinking" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [ "qwen3-30b-thinking" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      group = "coding";
      opencode = {
        displayName = "Qwen3 30B Thinking";
        reasoning = true;
        toolCall = true;
        outputLimit = 32768;
      };
    };

    "Qwen3-30B-Thinking-Speculative" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [ "qwen3-30b-thinking-spec" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      group = "coding";
      # speculative decoding
      draftModel = "unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL";
      draftConfig = {
        gpuLayers = 99;
        maxTokens = 16;
        minTokens = 1;
        pMin = 0.8;
      };
      opencode = {
        displayName = "Qwen3 30B Thinking Speculative";
        reasoning = true;
        toolCall = true;
        outputLimit = 32768;
      };
    };

    "Qwen3-4B-Thinking" = {
      hf = "unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [ "qwen3-4b-thinking" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      group = "coding";
      opencode = {
        displayName = "Qwen3 4B Thinking";
        reasoning = true;
        toolCall = true;
        outputLimit = 32768;
      };
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
      opencode = {
        displayName = "GPT-OSS 20B";
        reasoning = true;
        toolCall = true;
        outputLimit = 131072;
      };
    };

    "GPT-OSS-120B" = {
      hf = "unsloth/gpt-oss-120b-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      aliases = [ "gpt-oss-120b" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
      ];
      opencode = {
        displayName = "GPT-OSS 120B";
        reasoning = true;
        toolCall = true;
        outputLimit = 131072;
      };
    };

    "GLM-4.5-Air" = {
      hf = "unsloth/GLM-4.5-Air-GGUF:Q4_K_M";
      ctxSize = 131072;
      flashAttn = false;
      aliases = [
        "glm4"
        "glm-4.5"
      ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
      ];
      opencode = {
        displayName = "GLM-4.5 Air";
        reasoning = false;
        toolCall = true;
        outputLimit = 98304;
      };
    };

    # Nemotron 3 Nano - NVIDIA hybrid MoE (30B total, ~3.5B active)
    # Uses <think> tokens, supports up to 1M context, 128K output
    "Nemotron-3-Nano-30B" = {
      hf = "unsloth/Nemotron-3-Nano-30B-A3B-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [
        "nemotron"
        "nemotron-nano"
        "nemotron-30b"
      ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-p 1.0"
      ];
      opencode = {
        displayName = "Nemotron 3 Nano 30B";
        reasoning = true;
        toolCall = true;
        outputLimit = 131072;
      };
    };

    # Nemotron 3 Nano - tool calling mode (lower temp per NVIDIA docs)
    "Nemotron-3-Nano-30B-Tools" = {
      hf = "unsloth/Nemotron-3-Nano-30B-A3B-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      aliases = [ "nemotron-tools" ];
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "Nemotron 3 Nano 30B Tools";
        reasoning = true;
        toolCall = true;
        outputLimit = 131072;
      };
    };
  };
}
