final: prev: {
  llama-swap = prev.callPackage ./llama-swap { };
  perles = prev.callPackage ./perles { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };
  ffmpeg-for-homebridge = prev.callPackage ./homebridge/ffmpeg-for-homebridge.nix { };

  # Override llama-cpp to specific version
  llama-cpp = prev.llama-cpp.overrideAttrs (old: rec {
    version = "7616";
    src = prev.fetchFromGitHub {
      owner = "ggerganov";
      repo = "llama.cpp";
      rev = "b${version}";
      hash = "sha256-MRc6ivio5v6zgz2LBAJnAb+kY1M6B5Mn+2e+CYogPEQ=";
    };
  });

  # Python package extensions
  python313 = prev.python313.override {
    packageOverrides = pyFinal: pyPrev: {
      en-core-web-sm = pyFinal.callPackage ./python-packages/en-core-web-sm.nix { };
    };
  };
  python313Packages = final.python313.pkgs;

  # Kokoro TTS FastAPI server
  kokoro-fastapi = prev.callPackage ./kokoro-fastapi { };
}
