final: prev: {
  llama-swap = prev.callPackage ./llama-swap { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };

  # Override llama-cpp to b7315 (Linux only - macOS has dylib version number issues)
  llama-cpp = if prev.stdenv.isLinux then
    prev.llama-cpp.overrideAttrs (old: rec {
      version = "7315";
      src = prev.fetchFromGitHub {
        owner = "ggerganov";
        repo = "llama.cpp";
        rev = "b${version}";
        hash = "sha256-5csvHyGqZhLf04+58Eco1QqSW0WQ564pHqa29Dwgqlw=";
      };
    })
  else
    prev.llama-cpp;
}
