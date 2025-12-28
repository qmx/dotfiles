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

  # GGUF artifact catalog - maps HuggingFace identifiers to file metadata
  # Used by fetchGGUF to download models with integrity verification
  ggufs = {
    # Single file format:
    # "org/repo-GGUF:quantization" = {
    #   file = "filename.gguf";
    #   sha256 = "sha256-...";
    # };
    #
    # Split file format:
    # "org/repo-GGUF:quantization" = {
    #   files = [
    #     { name = "filename-00001-of-00002.gguf"; sha256 = "sha256-..."; }
    #     { name = "filename-00002-of-00002.gguf"; sha256 = "sha256-..."; }
    #   ];
    # };
    #
    # VL model format (with mmproj projection file):
    # "org/repo-GGUF:quantization" = {
    #   file = "main-model.gguf";
    #   sha256 = "sha256-...";
    #   mmproj = {
    #     file = "mmproj-F16.gguf";
    #     sha256 = "sha256-...";
    #   };
    # };

    "unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL" = {
      file = "SmolLM3-3B-128K-UD-Q4_K_XL.gguf";
      sha256 = "sha256-Dk5XZZMJm2crAu5bUWmD0121btKe7vX5E1Yz0zm/HnQ=";
    };

    "unsloth/gemma-3-27b-it-GGUF:Q4_K_XL" = {
      file = "gemma-3-27b-it-UD-Q4_K_XL.gguf";
      sha256 = "sha256-StmUED/SiqfoVKPPHxTxVJnaZ0Rv3kX+6z2011XbKIY=";
      mmproj = {
        file = "mmproj-F16.gguf";
        sha256 = "sha256-3r4lRYMaJWbc7IGZK5qo+oOBxaCjWIwLWaQcycYQz+c=";
      };
    };

    "unsloth/gpt-oss-20b-GGUF:Q8_K_XL" = {
      file = "gpt-oss-20b-UD-Q8_K_XL.gguf";
      sha256 = "sha256-uX+p8++mQu86vVmaFw8LJmEuUXmk71xl+4hS+5dOwjk=";
    };

    "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_K_XL" = {
      file = "Qwen3-Coder-30B-A3B-Instruct-UD-Q8_K_XL.gguf";
      sha256 = "sha256-yGetwqX4I85k9aoHF688S2YJWcPxbCPF9w97+Lp5Xig=";
    };

    "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M" = {
      file = "Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf";
      sha256 = "sha256-+tw+X41Cv36JSnhbBQguR9ruTfJmgDiYF+IJMFbwiK0=";
    };

    "unsloth/Qwen3-VL-4B-Thinking-GGUF:Q8_K_XL" = {
      file = "Qwen3-VL-4B-Thinking-UD-Q8_K_XL.gguf";
      sha256 = "sha256-o9dojgU94bVPq1jH3Fk+ZvQQq9SBDbt9w/+3xYDzelY=";
      mmproj = {
        file = "mmproj-F16.gguf";
        sha256 = "sha256-cjVPzT/HWTW4TnRcpJLW543QA7taAg1xspbnZQkmrIc=";
      };
    };

    "unsloth/Qwen3-VL-30B-A3B-Thinking-GGUF:Q8_K_XL" = {
      file = "Qwen3-VL-30B-A3B-Thinking-UD-Q8_K_XL.gguf";
      sha256 = "sha256-7/XrzX1lPN1Tr3CLPP90QLS85jPB7Vs55a0icj47vJY=";
      mmproj = {
        file = "mmproj-F16.gguf";
        sha256 = "sha256-dS+PZxceHTx1K2OLGyEKTHXdBzEgBZX0lu+LJgQM410=";
      };
    };

    "unsloth/Qwen3-VL-30B-A3B-Instruct-GGUF:Q8_K_XL" = {
      file = "Qwen3-VL-30B-A3B-Instruct-UD-Q8_K_XL.gguf";
      sha256 = "sha256-NY5sqtBVR4DCeGG0Y5wDuu7pF4jkVeEGbZz04K1CtVY=";
      mmproj = {
        file = "mmproj-F16.gguf";
        sha256 = "sha256-fnzsZ6Ooh73b84CZc40IVw6F8I3RJlePoAp6z02s7wE=";
      };
    };

    "unsloth/Qwen3-Next-80B-A3B-Thinking-GGUF:Q4_K_XL" = {
      file = "Qwen3-Next-80B-A3B-Thinking-UD-Q4_K_XL.gguf";
      sha256 = "sha256-SsJ2efg6lhbJqwWSDAqryfnBk5NGqZjh0LQ90gBR3Mo=";
    };

    "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q4_K_XL" = {
      file = "Qwen3-Next-80B-A3B-Instruct-UD-Q4_K_XL.gguf";
      sha256 = "sha256-LgveTHbFzywljP0Jwzv3R7R9Gg+rYWdw002eZ4hbpfs=";
    };

    "unsloth/gpt-oss-120b-GGUF:Q8_K_XL" = {
      files = [
        {
          name = "UD-Q8_K_XL/gpt-oss-120b-UD-Q8_K_XL-00001-of-00002.gguf";
          sha256 = "sha256-6xaAL+71gKlKiGLmct8pX2j8hITSzM8OElOfA4YUR2g=";
        }
        {
          name = "UD-Q8_K_XL/gpt-oss-120b-UD-Q8_K_XL-00002-of-00002.gguf";
          sha256 = "sha256-KwCVJR07HPmkyp1viieTcVQi+Q6UaMorPe73ZqNoptk=";
        }
      ];
    };

    # Whisper models (ggerganov/whisper.cpp)
    "ggerganov/whisper.cpp:large-v3-turbo" = {
      file = "ggml-large-v3-turbo.bin";
      sha256 = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
    };

    # Silero VAD model for whisper-cpp
    "ggml-org/whisper-vad:silero-v6.2.0" = {
      file = "ggml-silero-v6.2.0.bin";
      sha256 = "sha256-KqJpt4XutTqCmDogUB3ffB2cSOM6tjpBORrGyff7aYc=";
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

    "Qwen3-Next-80B-Instruct-Q4-256K" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q4_K_XL";
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
        displayName = "Qwen3 Next 80B Instruct Q4 256K";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 16384;
      };
    };

    "Qwen3-Next-80B-Instruct-Q4-256K-KVQ8" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q4_K_XL";
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
        displayName = "Qwen3 Next 80B Instruct Q4 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 16384;
      };
    };

    "Qwen3-Next-80B-Instruct-Q6-256K-KVQ8" = {
      hf = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q6_K_XL";
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
        displayName = "Qwen3 Next 80B Instruct Q6 256K KVQ8";
        reasoning = false;
        toolCall = true;
        contextLimit = 262144;
        outputLimit = 16384;
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

    # Qwen3-VL-4B-Thinking - Small VL model for testing
    # Docs: https://unsloth.ai/docs/models/qwen3-vl-how-to-run-and-fine-tune
    "Qwen3-VL-4B-Thinking-Q8-32K-KVQ8" = {
      hf = "unsloth/Qwen3-VL-4B-Thinking-GGUF:Q8_K_XL";
      ctxSize = 32768;
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
        displayName = "Qwen3 VL 4B Thinking Q8 32K KVQ8";
        reasoning = true;
        toolCall = true;
        contextLimit = 32768;
        outputLimit = 40960;
      };
    };
  };
}
