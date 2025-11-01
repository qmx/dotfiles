{ lib
, python3
, writeShellScriptBin
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    click
    huggingface-hub
    rich
  ]);
in
writeShellScriptBin "gguf-downloader" ''
  exec ${pythonEnv}/bin/python3 ${./gguf_downloader.py} "$@"
''
