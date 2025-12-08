{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  python3,
  rsync,
  ffmpeg,
  makeWrapper,
}:

buildNpmPackage rec {
  pname = "homebridge-camera-ffmpeg";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "homebridge-plugins";
    repo = "homebridge-camera-ffmpeg";
    rev = "v${version}";
    hash = "sha256-L0KWpV+G4455yRScgA+js9pc3DSgSmrEzUX2rOJ7HaM=";
  };

  npmDepsHash = "sha256-eJUpdI+MVBUE9ea8jP92Aq1D0hTT5x9hvG9bd4JNivY=";

  # We need to ignore scripts because ffmpeg-for-homebridge tries to download binaries
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    python3
    nodejs_22
    rsync
    makeWrapper
  ];

  buildInputs = [
    ffmpeg
  ];

  # The package needs to be built from TypeScript and copy UI files
  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    # Compile TypeScript and copy UI files
    npm run build

    runHook postBuild
  '';

  # Don't run tests during build
  doCheck = false;

  # After installation, wrap to ensure ffmpeg is in PATH
  postInstall = ''
    # Wrap any binaries if they exist
    if [ -d "$out/bin" ]; then
      for prog in $out/bin/*; do
        wrapProgram "$prog" \
          --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
      done
    fi
  '';

  meta = with lib; {
    description = "Homebridge Plugin Providing FFmpeg-based Camera Support";
    homepage = "https://github.com/homebridge-plugins/homebridge-camera-ffmpeg";
    license = licenses.isc;
    maintainers = [ ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
