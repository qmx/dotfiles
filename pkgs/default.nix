{
  pkgs-unstable ? null,
  pkgs-stable-pinned ? null,
}:
final: prev:
let
  # Use unstable playwright-driver if available (needed for agent-browser)
  playwrightDriver =
    if pkgs-unstable != null then pkgs-unstable.playwright-driver else prev.playwright-driver;
in
{
  agent-browser = prev.callPackage ./agent-browser { playwright-driver = playwrightDriver; };
  agent-browser-skill = prev.callPackage ./agent-browser-skill { };
  llama-swap = prev.callPackage ./llama-swap { };
  ralph-tui = prev.callPackage ./ralph-tui { };
  homebridge = prev.callPackage ./homebridge/package.nix { };
  homebridge-camera-ffmpeg = prev.callPackage ./homebridge/camera-ffmpeg.nix { };
  ffmpeg-for-homebridge = prev.callPackage ./homebridge/ffmpeg-for-homebridge.nix { };

  # Override llama-cpp to specific version
  llama-cpp = prev.llama-cpp.overrideAttrs (old: rec {
    version = "7825";
    src = prev.fetchFromGitHub {
      owner = "ggerganov";
      repo = "llama.cpp";
      rev = "b${version}";
      hash = "sha256-KeXcNabEbXVy2jttCaH7Z61m1o6Zvcl0z9eALuT2rwI=";
    };
  });

  # Python package extensions
  python313 = prev.python313.override {
    packageOverrides = pyFinal: pyPrev: {
      en-core-web-sm = pyFinal.callPackage ./python-packages/en-core-web-sm.nix { };
    };
  };
  python313Packages = final.python313.pkgs;

  # Kokoro TTS FastAPI server (pinned to older nixpkgs for python deps compatibility)
  kokoro-fastapi =
    if pkgs-stable-pinned != null then
      pkgs-stable-pinned.callPackage ./kokoro-fastapi { }
    else
      prev.callPackage ./kokoro-fastapi { };
}
