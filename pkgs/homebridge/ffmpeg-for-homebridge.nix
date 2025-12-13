{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "ffmpeg-for-homebridge";
  version = "2.2.0";

  src = fetchurl {
    url = "https://github.com/homebridge/ffmpeg-for-homebridge/releases/download/v${version}/ffmpeg-alpine-aarch64.tar.gz";
    hash = "sha256-PtFyRTOSG2tU0f01gCr2Kr0p6GcuCvuUuy+MGBWDI6M=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r usr/local/bin/* $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Static FFmpeg binaries for Homebridge with libfdk-aac support";
    homepage = "https://github.com/homebridge/ffmpeg-for-homebridge";
    license = licenses.gpl3Plus;
    platforms = [ "aarch64-linux" ];
    mainProgram = "ffmpeg";
  };
}
