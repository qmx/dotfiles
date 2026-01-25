{
  lib,
  stdenv,
  fetchFromGitHub,
}:

let
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "subsy";
    repo = "ralph-tui";
    rev = "v${version}";
    hash = "sha256-0RWoWl8qsnLSPMtGUvHFVHxGmxfgFGO77a4cFGVdd+Y=";
  };
in
stdenv.mkDerivation {
  pname = "ralph-tui-skill";
  inherit version src;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/opencode/skills/ralph-tui-prd
    cp -r skills/ralph-tui-prd/* $out/share/opencode/skills/ralph-tui-prd/

    runHook postInstall
  '';

  meta = {
    description = "ralph-tui-prd skill for OpenCode";
    homepage = "https://github.com/subsy/ralph-tui";
    license = lib.licenses.mit;
  };
}
