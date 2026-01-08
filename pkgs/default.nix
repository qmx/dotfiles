final: prev: {
  llama-swap = prev.callPackage ./llama-swap { };
  perles = prev.callPackage ./perles { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };
  ffmpeg-for-homebridge = prev.callPackage ./homebridge/ffmpeg-for-homebridge.nix { };

  # Override llama-cpp to specific version
  llama-cpp = prev.llama-cpp.overrideAttrs (old: rec {
    version = "7664";
    src = prev.fetchFromGitHub {
      owner = "ggerganov";
      repo = "llama.cpp";
      rev = "b${version}";
      hash = "sha256-Bq1elca595YC+2m79W6gIqC3UTs0+ad7qwKMMPFgBuM=";
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
