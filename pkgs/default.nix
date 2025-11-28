final: prev: {
  llama-swap = prev.callPackage ./llama-swap { };
  gguf-downloader = prev.callPackage ./gguf-downloader { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };
}
