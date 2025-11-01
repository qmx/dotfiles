final: prev: {
  llama-swap = prev.callPackage ./llama-swap { };
  gguf-downloader = prev.callPackage ./gguf-downloader { };
}
