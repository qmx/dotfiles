{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs_22
, python3
, openssl
}:

buildNpmPackage rec {
  pname = "homebridge";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "homebridge";
    repo = "homebridge";
    rev = "v${version}";
    hash = "sha256-E21HowCRD78MZW3+um6vN5/NLncF/bt9v/Tw+RYe5xM=";
  };

  npmDepsHash = "sha256-Da64zHwvX0W1viNhy4afr60onlWqbizaVox9Un6c65Y=";

  nativeBuildInputs = [
    python3
    nodejs_22
  ];

  buildInputs = [
    openssl
  ];

  # The package needs to be built from TypeScript
  # We can't use the default "build" script because it tries to npm install rimraf
  # which doesn't work in Nix sandbox. Instead, we manually build.
  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    # Clean any existing lib directory
    rm -rf lib/

    # Compile TypeScript
    npx tsc

    runHook postBuild
  '';

  # Don't run tests during build (they require additional setup)
  doCheck = false;

  meta = with lib; {
    description = "HomeKit support for the impatient";
    homepage = "https://github.com/homebridge/homebridge";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "homebridge";
  };
}
