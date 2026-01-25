{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  makeWrapper,
  cacert,
}:

let
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "subsy";
    repo = "ralph-tui";
    rev = "v${version}";
    hash = "sha256-0RWoWl8qsnLSPMtGUvHFVHxGmxfgFGO77a4cFGVdd+Y=";
  };

  bunDeps = stdenv.mkDerivation {
    pname = "ralph-tui-deps";
    inherit version src;
    nativeBuildInputs = [
      bun
      cacert
    ];
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-e4ISNTCmsV24kQFHDAtuEOK6o1CKxixSf1+ofGAUzOA=";
    buildPhase = ''
      export HOME=$TMPDIR
      bun install --frozen-lockfile
    '';
    installPhase = "cp -r node_modules $out";
    dontFixup = true;
  };
in
stdenv.mkDerivation {
  pname = "ralph-tui";
  inherit version src;
  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  buildPhase = ''
    export HOME=$TMPDIR
    cp -r ${bunDeps} node_modules
    chmod -R u+w node_modules

    # Build (from package.json)
    bun build ./src/cli.tsx --outdir ./dist --target bun --sourcemap=external
    bun build ./src/index.ts --outdir ./dist --target bun --sourcemap=external

    # Copy assets
    cp -r assets dist/
    cp -r skills dist/

    # Copy templates
    mkdir -p dist/plugins/trackers/builtin/{beads,beads-bv,json,beads-rust}
    cp src/plugins/trackers/builtin/beads/template.hbs dist/plugins/trackers/builtin/beads/
    cp src/plugins/trackers/builtin/beads-bv/template.hbs dist/plugins/trackers/builtin/beads-bv/
    cp src/plugins/trackers/builtin/json/template.hbs dist/plugins/trackers/builtin/json/
    cp src/plugins/trackers/builtin/beads-rust/template.hbs dist/plugins/trackers/builtin/beads-rust/
  '';

  installPhase = ''
    mkdir -p $out/lib/ralph-tui
    cp -r dist node_modules package.json $out/lib/ralph-tui/

    mkdir -p $out/bin
    makeWrapper ${bun}/bin/bun $out/bin/ralph-tui \
      --add-flags "$out/lib/ralph-tui/dist/cli.js" \
      --set NODE_PATH "$out/lib/ralph-tui/node_modules"
  '';

  meta = {
    description = "AI Agent Loop Orchestrator - TUI for managing AI agent workflows";
    homepage = "https://github.com/subsy/ralph-tui";
    license = lib.licenses.mit;
    mainProgram = "ralph-tui";
    platforms = lib.platforms.unix;
  };
}
