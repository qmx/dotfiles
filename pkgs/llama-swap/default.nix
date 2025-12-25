{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
}:

let
  version = "178";

  src = fetchFromGitHub {
    owner = "mostlygeek";
    repo = "llama-swap";
    rev = "v${version}";
    hash = "sha256-/d0wNOky5zr4t4d2qy7tS6Zj+nTghtcU9ZuWQ/y2MTo=";
  };

  # Build the UI component separately
  ui = buildNpmPackage {
    pname = "llama-swap-ui";
    inherit version src;

    sourceRoot = "${src.name}/ui";

    npmDepsHash = "sha256-RKPcMwJ0qVOgbTxoGryrLn7AW0Bfmv9WasoY+gw4B30=";

    buildPhase = ''
      runHook preBuild
      # Build with custom outDir to stay within the ui directory
      npm exec tsc -- -b
      npm exec vite -- build --outDir dist
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';

    dontFixup = true;
  };
in
buildGoModule rec {
  pname = "llama-swap";
  inherit version src;

  # Go vendor hash
  vendorHash = "sha256-/EbFyuCVFxHTTO0UwSV3B/6PYUpudxB2FD8nNx1Bb+M=";

  # Skip tests - they require additional build artifacts
  doCheck = false;

  # Copy pre-built UI into place before building Go binary
  preBuild = ''
    # Copy the pre-built UI
    cp -r ${ui} proxy/ui_dist
    chmod -R u+w proxy/ui_dist
  '';

  # Pass version info via ldflags
  ldflags = [
    "-X main.version=${version}"
    "-X main.commit=local"
    "-X main.date=1970-01-01T00:00:00Z"
  ];

  meta = {
    description = "Model management proxy that enables hot-swapping between LLM models";
    homepage = "https://github.com/mostlygeek/llama-swap";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "llama-swap";
  };
}
