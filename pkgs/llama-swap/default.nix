{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
}:

let
  version = "186";

  src = fetchFromGitHub {
    owner = "mostlygeek";
    repo = "llama-swap";
    rev = "v${version}";
    hash = "sha256-WQLYRG3n1GAhxMZvA5gQ7nSILNca1MZFJpqfz+5EjOU=";
  };

  # Build the UI component separately
  ui = buildNpmPackage {
    pname = "llama-swap-ui";
    inherit version src;

    sourceRoot = "${src.name}/ui";

    npmDepsHash = "sha256-xz4z/Bxlbw7uuzRP0aWPRKSfhPAB++iToYnymu4RVSE=";

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
  vendorHash = "sha256-XiDYlw/byu8CWvg4KSPC7m8PGCZXtp08Y1velx4BR8U=";

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
