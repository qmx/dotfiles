{ pkgs-unstable ? null }:
final: prev:
let
  # Use unstable playwright-driver if available (needed for agent-browser)
  playwrightDriver = if pkgs-unstable != null then pkgs-unstable.playwright-driver else prev.playwright-driver;
in
{
  agent-browser = prev.callPackage ./agent-browser { playwright-driver = playwrightDriver; };
  llama-swap = prev.callPackage ./llama-swap { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };
  ffmpeg-for-homebridge = prev.callPackage ./homebridge/ffmpeg-for-homebridge.nix { };

  # Override llama-cpp to specific version
  llama-cpp = prev.llama-cpp.overrideAttrs (old: rec {
    version = "7735";
    src = prev.fetchFromGitHub {
      owner = "ggerganov";
      repo = "llama.cpp";
      rev = "b${version}";
      hash = "sha256-8t5UT/rx4guZe0qHtNb8DCZk6+qKwyeLu+anidw7T8M=";
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
