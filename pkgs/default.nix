final: prev: {
  beads-viewer = prev.callPackage ./beads-viewer { };
  llama-swap = prev.callPackage ./llama-swap { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };
  ffmpeg-for-homebridge = prev.callPackage ./homebridge/ffmpeg-for-homebridge.nix { };

  # Override llama-cpp to b7524 (Linux only - macOS has dylib version number issues)
  llama-cpp =
    if prev.stdenv.isLinux then
      prev.llama-cpp.overrideAttrs (old: rec {
        version = "7524";
        src = prev.fetchFromGitHub {
          owner = "ggerganov";
          repo = "llama.cpp";
          rev = "b${version}";
          hash = "sha256-8mnlR7NnD+LX3Vqyr3dtvfNzpVvQq9i9WdsHje9eFj4=";
        };
      })
    else
      prev.llama-cpp;
}
