# Model catalog for llama-swap and opencode
{
  # Import GGUF artifact catalog - maps HuggingFace identifiers to file metadata
  ggufs = import ./ggufs.nix;

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

    "SmolLM3-3B-Q8-128K-KVQ8" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q8_K_XL";
      ctxSize = 131072;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q8 128K KVQ8";
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

    "SmolLM3-3B-Q4-64K-KVQ8" = {
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
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
      opencode = {
        displayName = "SmolLM3 3B Q4 64K KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 65536;
        outputLimit = 32768;
      };
    };

    "SmolLM3-3B-Q4-32K-2x" = {
      hf = "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL";
      ctxSize = 32768;
      parallel = 2;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
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
      ctxSize = 65536;
      parallel = 4;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
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

    "Qwen3-Coder-30B-Q4-200K" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_XL";
      ctxSize = 204800;
      flashAttn = true;
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
        displayName = "Qwen3 Coder 30B Q4 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q5-200K" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q5_K_XL";
      ctxSize = 204800;
      flashAttn = true;
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
        displayName = "Qwen3 Coder 30B Q5 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 65536;
      };
    };

    "Qwen3-Coder-30B-Q8-200K" = {
      hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
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
        displayName = "Qwen3 Coder 30B Q8 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 65536;
      };
    };

    "Qwen3-Next-80B-Thinking-Q4-200K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q4_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Thinking Q4 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 32768;
      };
    };

    "Qwen3-Next-80B-Thinking-Q8-200K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Thinking Q8 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 32768;
      };
    };

    "Qwen3-Next-80B-Instruct-Q4-200K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q4_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Instruct Q4 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 16384;
      };
    };

    "Qwen3-Next-80B-Instruct-Q8-200K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 Next 80B Instruct Q8 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 16384;
      };
    };

    "Qwen3-30B-Thinking-2507-Q4-200K" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q4_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 30B Thinking 2507 Q4 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 32768;
      };
    };

    "Qwen3-30B-Thinking-2507-Q8-200K" = {
      hf = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 30B Thinking 2507 Q8 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 32768;
      };
    };

    "Qwen3-30B-Instruct-2507-Q4-200K" = {
      hf = "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q4_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 30B Instruct 2507 Q4 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 16384;
      };
    };

    "Qwen3-30B-Instruct-2507-Q8-200K" = {
      hf = "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 30B Instruct 2507 Q8 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 16384;
      };
    };

    "Qwen3-4B-Thinking-2507-Q8-200K" = {
      hf = "unsloth/Qwen3-4B-Thinking-2507-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = false;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.6"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 4B Thinking 2507 Q8 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 204800;
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

    "GLM-4.7-Flash-Q4-200K" = {
      hf = "unsloth/GLM-4.7-Flash-GGUF:Q4_K_XL";
      ctxSize = 202752;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 1.0"
        "--min-p 0.01"
      ];
      opencode = {
        displayName = "GLM 4.7 Flash Q4 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 202752;
        outputLimit = 16384;
      };
    };

    "GLM-4.7-Flash-Q5-200K" = {
      hf = "unsloth/GLM-4.7-Flash-GGUF:Q5_K_XL";
      ctxSize = 202752;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 1.0"
        "--min-p 0.01"
      ];
      opencode = {
        displayName = "GLM 4.7 Flash Q5 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 202752;
        outputLimit = 16384;
      };
    };

    "GLM-4.7-Flash-Q8-200K" = {
      hf = "unsloth/GLM-4.7-Flash-GGUF:Q8_K_XL";
      ctxSize = 202752;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 1.0"
        "--min-p 0.01"
      ];
      opencode = {
        displayName = "GLM 4.7 Flash Q8 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 202752;
        outputLimit = 16384;
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

    "Devstral-Small-2-24B-2512-Q8-200K-KVQ8" = {
      hf = "unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF:Q8_K_XL";
      ctxSize = 204800;
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
        displayName = "Devstral Small 2 24B 2512 Q8 200K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 32768;
      };
    };

    "Devstral-Small-2-24B-2512-Q4-128K-KVQ8" = {
      hf = "unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF:Q4_K_XL";
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
        displayName = "Devstral Small 2 24B 2512 Q4 128K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 131072;
        outputLimit = 32768;
      };
    };

    # Qwen3-VL - Vision-Language Models (MoE)
    # Docs: https://docs.unsloth.ai/models/qwen3-vl-how-to-run-and-fine-tune
    "Qwen3-VL-30B-Thinking-Q8-200K" = {
      hf = "unsloth/Qwen3-VL-30B-A3B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 VL 30B Thinking Q8 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 32768;
      };
    };

    "Qwen3-VL-30B-Instruct-Q8-200K" = {
      hf = "unsloth/Qwen3-VL-30B-A3B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 VL 30B Instruct Q8 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 16384;
      };
    };

    # Qwen3-VL-32B - Dense Vision-Language Model (not MoE)
    # Docs: https://huggingface.co/unsloth/Qwen3-VL-32B-Instruct-GGUF
    "Qwen3-VL-32B-Instruct-Q8-200K" = {
      hf = "unsloth/Qwen3-VL-32B-Instruct-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 0.7"
        "--top-p 0.8"
        "--top-k 20"
        "--repeat-penalty 1.05"
      ];
      opencode = {
        displayName = "Qwen3 VL 32B Instruct Q8 200K";
        reasoning = false;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 16384;
      };
    };

    # Qwen3-VL-4B-Thinking - Small VL model for testing
    # Docs: https://unsloth.ai/docs/models/qwen3-vl-how-to-run-and-fine-tune
    "Qwen3-VL-4B-Thinking-Q8-200K" = {
      hf = "unsloth/Qwen3-VL-4B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 204800;
      flashAttn = true;
      extraArgs = [
        "--jinja"
        "-ngl 99"
        "--temp 1.0"
        "--top-p 0.95"
        "--top-k 20"
      ];
      opencode = {
        displayName = "Qwen3 VL 4B Thinking Q8 200K";
        reasoning = true;
        toolCall = true;
        contextLimit = 204800;
        outputLimit = 32768;
      };
    };
  };
}
