final: prev: {
  llama-swap = prev.callPackage ./llama-swap { };
  gguf-downloader = prev.callPackage ./gguf-downloader { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };

  # Override llama-cpp to b7188 (Linux only - macOS has dylib version number issues)
  llama-cpp = if prev.stdenv.isLinux then
    prev.llama-cpp.overrideAttrs (old: rec {
      version = "7188";
      src = prev.fetchFromGitHub {
        owner = "ggerganov";
        repo = "llama.cpp";
        rev = "b${version}";
        hash = "sha256-fmnqiDt2735TeUdUJgF+hFYgZ7TCreVHqVKbLYTSGdQ=";
      };
    })
  else
    prev.llama-cpp;
}
