{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  playwright-driver,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  jq,
}:

let
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "6abee3764105ca823f4688bb799279e447671f55"; # v0.5.0
    hash = "sha256-0eSd6crb5JB7OvEBwW0Y4B24SiZwUHUYZf+1Kmdfn4Y=";
  };

  # Build the Rust CLI separately
  rustCli = rustPlatform.buildRustPackage {
    pname = "agent-browser-cli";
    inherit version src;
    sourceRoot = "${src.name}/cli";
    cargoHash = "sha256-B/Yqg6GVqhKBdjlvnVa4Mlp1laGY5sDIEQXdLPz64oM=";

    meta = {
      description = "Native CLI for agent-browser";
      license = lib.licenses.asl20;
    };
  };

  # Full playwright browsers (includes chromium_headless_shell needed for headless mode)
  playwrightBrowsers = playwright-driver.browsers;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  inherit version src;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3; # For pnpm lockfile v9
    hash = "sha256-D/X7Z1o/cQ23/1wXixscBkIL4Kah4lIK+5/fGFqYDpo=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    makeWrapper
    jq
  ];

  preBuild = ''
    # Remove husky prepare script (not needed in Nix build)
    ${jq}/bin/jq 'del(.scripts.prepare)' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/agent-browser
    cp -r dist $out/lib/agent-browser/
    cp -r node_modules $out/lib/agent-browser/
    cp package.json $out/lib/agent-browser/

    # Install native CLI binary
    install -Dm755 ${rustCli}/bin/agent-browser $out/bin/agent-browser

    # Create dist symlink so CLI can find daemon.js (looks for ../dist/daemon.js from bin/)
    mkdir -p $out/dist
    ln -s $out/lib/agent-browser/dist/daemon.js $out/dist/daemon.js

    # Wrap to set playwright browser path, NODE_PATH, and ensure node is in PATH
    wrapProgram $out/bin/agent-browser \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwrightBrowsers}" \
      --set NODE_PATH "$out/lib/agent-browser/node_modules" \
      --prefix PATH : "${nodejs}/bin"

    # Also wrap the Node.js entry point
    makeWrapper ${nodejs}/bin/node $out/bin/agent-browser-node \
      --add-flags "$out/lib/agent-browser/dist/daemon.js" \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwrightBrowsers}" \
      --set NODE_PATH "$out/lib/agent-browser/node_modules"

    runHook postInstall
  '';

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "agent-browser";
  };
})
