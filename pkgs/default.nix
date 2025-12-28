final: prev: {
  llama-swap = prev.callPackage ./llama-swap { };
  perles = prev.callPackage ./perles { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };
  ffmpeg-for-homebridge = prev.callPackage ./homebridge/ffmpeg-for-homebridge.nix { };

  # Override llama-cpp to b7539 (Linux only - macOS has dylib version number issues)
  llama-cpp =
    if prev.stdenv.isLinux then
      prev.llama-cpp.overrideAttrs (old: rec {
        version = "7539";
        src = prev.fetchFromGitHub {
          owner = "ggerganov";
          repo = "llama.cpp";
          rev = "b${version}";
          hash = "sha256-jAHLfoWnZrLZ5noTpK/oN5R+jllnd7IBygFtWbg6mwE=";
        };
      })
    else
      prev.llama-cpp;

  # Python package extensions
  python313 = prev.python313.override {
    packageOverrides = pyFinal: pyPrev: {
      en-core-web-sm = pyFinal.callPackage ./python-packages/en-core-web-sm.nix { };
    };
  };
  python313Packages = final.python313.pkgs;
}
