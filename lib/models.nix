# Model catalog for llama-swap and opencode
{
  # Group configurations - models in same group coexist without swapping
  groupConfigs = {
    coding = {
      swap = false;
      exclusive = false;
    };
    always-on = {
      persistent = true;
      swap = false;
      exclusive = false;
    };
  };

  models = {
    "SmolLM3-3B-Q4-128K" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q4 128K";
        reasoning = true;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-Q8-128K" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q8 128K";
        reasoning = true;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-Q4-32K" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 32768;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q4 32K";
        reasoning = true;
        toolCall = true;
        contextLimit = 32768;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-Q4-64K" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 65536;
      flashAttn = false;
      group = "always-on";
      ttl = 120;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q4 64K";
        reasoning = true;
        toolCall = true;
        contextLimit = 65536;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-Q4-32K-2x" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 65536;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 2"
        "--cont-batching"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      group = "coding";
      opencode = {
        displayName = "SmolLM3 3B Q4 32K 2x";
        reasoning = true;
        toolCall = true;
        contextLimit = 32768;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-Q4-64K-4x" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q4 64K 4x";
        reasoning = true;
        toolCall = true;
        contextLimit = 65536;
        outputLimit = 32768;
      };
    };

    "Gemma-3-12B-Q4-128K" = {
      hf = "unsloth/gemma-3-12b-it-qat-int4-GGUF:Q4_K_XL";
      ctxSize = 131072;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-k 64"
        "--top-p 0.95"
        "--min-p 0.0"
      ];
      opencode = {
        displayName = "Gemma 3 12B Q4 128K";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 8192;
      };
    };

    "Gemma-3-27B-Q4-128K" = {
      hf = "unsloth/gemma-3-27b-it-GGUF:Q4_K_XL";
      ctxSize = 131072;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-k 64"
        "--top-p 0.95"
        "--min-p 0.0"
      ];
      opencode = {
        displayName = "Gemma 3 27B Q4 128K";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 8192;
      };
    };

    "Llama-3.1-8B-Q8-128K" = {
      hf = "unsloth/Llama-3.1-8B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.9"
        "--top-k 40"
        "--repeat-penalty 1.1"
      ];
      opencode = {
        displayName = "Llama 3.1 8B Q8 128K";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 8192;
      };
    };

    "Qwen3-Coder-30B-Q8-256K" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 256K";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-256K-2x" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 2"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 256K 2x";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-256K-2x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 2"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 256K 2x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-128K-4x" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 128K 4x";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-128K-4x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 128K 4x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q4-256K" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q4 256K";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q4-256K-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q4 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q4-256K-2x" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 2"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q4 256K 2x";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q4-256K-2x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 2"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q4 256K 2x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q4-128K-4x" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q4 128K 4x";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q4-128K-4x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q4 128K 4x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q6-128K-4x" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q6_K_XL";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q6 128K 4x";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q6-128K-4x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q6_K_XL";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q6 128K 4x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q6-256K-4x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q6_K_XL";
      ctxSize = 1048576;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q6 256K 4x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-256K-4x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 1048576;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 256K 4x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-200K-3x-KVQ8" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 614400;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 3"
        "--cont-batching"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      group = "coding";
      opencode = {
        displayName = "Qwen3 Coder 30B Q8 200K 3x KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 65536;
      };
    };

    "Qwen3-Next-80B-Thinking-Q4-256K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q4_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Thinking Q4 256K";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "Qwen3-Next-80B-Thinking-Q4-256K-KVQ8" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q4_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Thinking Q4 256K KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "Qwen3-Next-80B-Instruct-Q8-256K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Instruct Q8 256K";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 16384;
      };
    };

    "Qwen3-Next-80B-Instruct-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Instruct Q8 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 16384;
      };
    };

    "Qwen3-Next-80B-Thinking-Q8-256K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Thinking Q8 256K";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "Qwen3-Next-80B-Thinking-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Thinking Q8 256K KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "Qwen3-30B-Instruct-2507-Q8-256K" = {
      hf = "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 30B Instruct 2507 Q8 256K";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 16384;
      };
    };

    "Qwen3-30B-Instruct-2507-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 30B Instruct 2507 Q8 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 16384;
      };
    };

    "Qwen3-30B-Thinking-2507-Q8-256K" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 30B Thinking 2507 Q8 256K";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "Qwen3-30B-Thinking-2507-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 30B Thinking 2507 Q8 256K KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "Qwen3-30B-Thinking-2507-Q6-128K-4x-KVQ8" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q6_K_XL";
      ctxSize = 524288;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--parallel 4"
        "--cont-batching"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
        "--repeat-penalty 1.1"
      ];
      opencode = {
        displayName = "Qwen3 30B Thinking 2507 Q6 128K 4x KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 32768;
      };
    };

    "Qwen3-30B-Thinking-2507-Q6-128K-1x-KVQ8" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q6_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      group = "coding";
      opencode = {
        displayName = "Qwen3 30B Thinking 2507 Q6 128K 1x KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 32768;
      };
    };

    "Qwen3-4B-Thinking-2507-Q8-256K" = {
      hf = "unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 4B Thinking 2507 Q8 256K";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "Qwen3-4B-Thinking-2507-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 4B Thinking 2507 Q8 256K KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    "GPT-OSS-20B-Q8-128K" = {
      hf = "unsloth/gpt-oss-20b-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
      ];
      opencode = {
        displayName = "GPT-OSS 20B Q8 128K";
        reasoning = true;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 131072;
      };
    };

    "GPT-OSS-120B-Q8-128K" = {
      hf = "unsloth/gpt-oss-120b-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
      ];
      opencode = {
        displayName = "GPT-OSS 120B Q8 128K";
        reasoning = true;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 131072;
      };
    };

    "GLM-4.5-Air-Q4-128K" = {
      hf = "unsloth/GLM-4.5-Air-GGUF:Q4_K_M";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
      ];
      opencode = {
        displayName = "GLM-4.5 Air Q4 128K";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 98304;
      };
    };

    # Nemotron 3 Nano - NVIDIA hybrid MoE (30B total, ~3.5B active)
    # Uses <think> tokens, supports up to 1M context, 128K output
    "Nemotron-3-Nano-30B-Q8-256K" = {
      hf = "unsloth/Nemotron-3-Nano-30B-A3B-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-p 1.0"
      ];
      opencode = {
        displayName = "Nemotron 3 Nano 30B Q8 256K";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 131072;
      };
    };

    # Nemotron 3 Nano - tool calling mode (lower temp per NVIDIA docs)
    "Nemotron-3-Nano-30B-Q8-256K-Tools" = {
      hf = "unsloth/Nemotron-3-Nano-30B-A3B-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
      ];
      opencode = {
        displayName = "Nemotron 3 Nano 30B Q8 256K Tools";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 131072;
      };
    };

    # Devstral 2 - Mistral AI coding models
    # Docs: https://docs.unsloth.ai/models/devstral-2
    "Devstral-2-123B-2512-Q4-128K-KVQ8" = {
      hf = "unsloth/Devstral-2-123B-Instruct-2512-GGUF:Q4_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.15"
        "--min-p 0.01"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Devstral 2 123B 2512 Q4 128K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 32768;
      };
    };

    "Devstral-Small-2-24B-2512-Q8-256K" = {
      hf = "unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.15"
        "--min-p 0.01"
      ];
      opencode = {
        displayName = "Devstral Small 2 24B 2512 Q8 256K";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    # Qwen3-VL - Vision-Language Models (MoE)
    # Docs: https://docs.unsloth.ai/models/qwen3-vl-how-to-run-and-fine-tune
    "Qwen3-VL-30B-Thinking-Q8-256K" = {
      hf = "unsloth/Qwen3-VL-30B-A3B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 VL 30B Thinking Q8 256K";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 40960;
      };
    };

    "Qwen3-VL-30B-Instruct-Q8-256K" = {
      hf = "unsloth/Qwen3-VL-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 VL 30B Instruct Q8 256K";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    # KVQ8 variants - quantized KV cache for reduced VRAM
    "Qwen3-VL-30B-Thinking-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-VL-30B-A3B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-p 0.95"
        "--top-k 20"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 VL 30B Thinking Q8 256K KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 40960;
      };
    };

    "Qwen3-VL-30B-Instruct-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-VL-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 VL 30B Instruct Q8 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };

    # Qwen3-VL-32B - Dense Vision-Language Model (not MoE)
    # Docs: https://huggingface.co/unsloth/Qwen3-VL-32B-Instruct-GGUF
    "Qwen3-VL-32B-Instruct-Q8-256K-KVQ8" = {
      hf = "unsloth/Qwen3-VL-32B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 262144;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "Qwen3 VL 32B Instruct Q8 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 32768;
      };
    };
  };
}
