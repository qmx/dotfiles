{
  lib,
  python313,
  fetchFromGitHub,
  fetchurl,
  espeak-ng,
  makeWrapper,
}:

let
  python = python313.override {
    packageOverrides = pyFinal: pyPrev: {
      en-core-web-sm = pyFinal.callPackage ../python-packages/en-core-web-sm.nix { };
      # dlinfo is marked broken on Darwin in nixpkgs, but phonemizer needs it
      # Tests fail on modern macOS because /usr/lib/libdl.dylib doesn't exist
      # (libdl is part of libSystem)
      dlinfo = pyPrev.dlinfo.overridePythonAttrs (old: {
        doCheck = false;
        meta = old.meta // {
          broken = false;
        };
      });
      # weasel uses typer-slim, but spacy uses typer - they conflict
      # Override weasel to use typer instead, disable runtime dep check
      weasel =
        (pyPrev.weasel.override {
          typer-slim = pyFinal.typer;
        }).overridePythonAttrs
          (old: {
            dontCheckRuntimeDeps = true;
          });
      # spacy also checks for typer-slim at runtime
      spacy = pyPrev.spacy.overridePythonAttrs (old: {
        dontCheckRuntimeDeps = true;
      });
    };
  };

  pythonEnv = python.withPackages (
    ps: with ps; [
      # Core TTS
      kokoro
      misaki
      en-core-web-sm

      # Web framework
      fastapi
      uvicorn
      pydantic
      pydantic-settings

      # Audio processing
      soundfile
      pydub
      av

      # Utilities
      aiofiles
      tqdm
      requests
      munch
      tiktoken
      loguru
      openai
      python-dotenv
      sqlalchemy
      inflect
      mutagen
      psutil

      # Required by kokoro/misaki
      numpy
      scipy
      regex
      torch
      spacy
    ]
  );

  # Fetch model files from GitHub release
  modelFile = fetchurl {
    url = "https://github.com/remsky/Kokoro-FastAPI/releases/download/v0.1.4/kokoro-v1_0.pth";
    hash = "sha256-SW26EY0aWPXz2y78iNvcIW4Eg/yJ/m5H7h8sU/GK0eQ=";
  };

  configFile = fetchurl {
    url = "https://github.com/remsky/Kokoro-FastAPI/releases/download/v0.1.4/config.json";
    hash = "sha256-WrsB4kA7ByvwPQT94WBEPiCdeg2tSaQjvhUZa5tDwX8=";
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "kokoro-fastapi";
  version = "0.3.0-unstable-2024-12-27";
  format = "other";

  src = fetchFromGitHub {
    owner = "remsky";
    repo = "Kokoro-FastAPI";
    rev = "6c1b8bf36c1da8ddb4aeb6fe694a4f5db2d6805a";
    hash = "sha256-dAC0Jq7vhKPzt7n09cO4okn8C/AqG294Ds/BJLlWPbk=";
  };

  # Don't try to build - we just need the source
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  # Create wrapper script
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/kokoro-fastapi

    # Copy source
    cp -r api $out/share/kokoro-fastapi/
    cp -r web $out/share/kokoro-fastapi/ || true

    # Create models directory and copy model files
    mkdir -p $out/share/kokoro-fastapi/api/src/models/v1_0
    cp ${modelFile} $out/share/kokoro-fastapi/api/src/models/v1_0/kokoro-v1_0.pth
    cp ${configFile} $out/share/kokoro-fastapi/api/src/models/v1_0/config.json

    # Create wrapper script
    makeWrapper ${pythonEnv}/bin/python $out/bin/kokoro-server \
      --add-flags "-m uvicorn api.src.main:app --host 0.0.0.0 --port 8880" \
      --set PYTHONPATH "$out/share/kokoro-fastapi" \
      --set USE_GPU "false" \
      --set USE_ONNX "false" \
      --set MODEL_DIR "$out/share/kokoro-fastapi/api/src/models" \
      --set VOICES_DIR "$out/share/kokoro-fastapi/api/src/voices/v1_0" \
      --set WEB_PLAYER_PATH "$out/share/kokoro-fastapi/web" \
      --set ESPEAK_DATA_PATH "${espeak-ng}/share/espeak-ng-data" \
      --prefix PATH : "${lib.makeBinPath [ espeak-ng ]}"

    runHook postInstall
  '';

  meta = {
    description = "FastAPI TTS service using Kokoro-82M model";
    homepage = "https://github.com/remsky/Kokoro-FastAPI";
    license = lib.licenses.asl20;
    mainProgram = "kokoro-server";
    platforms = lib.platforms.unix;
  };
}
