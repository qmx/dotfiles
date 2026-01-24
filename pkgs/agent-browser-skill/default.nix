{
  lib,
  stdenv,
  fetchFromGitHub,
}:

let
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "6abee3764105ca823f4688bb799279e447671f55";
    hash = "sha256-0eSd6crb5JB7OvEBwW0Y4B24SiZwUHUYZf+1Kmdfn4Y=";
  };
in
stdenv.mkDerivation {
  pname = "agent-browser-skill";
  inherit version src;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/opencode/skills/agent-browser
    cp -r skills/agent-browser/* $out/share/opencode/skills/agent-browser/

    runHook postInstall
  '';

  meta = {
    description = "agent-browser skill files for OpenCode";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
