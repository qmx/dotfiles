{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

let
  version = "0.10.2";
in
buildGoModule {
  pname = "beads-viewer";
  inherit version;

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "beads_viewer";
    rev = "v${version}";
    hash = "sha256-GteCe909fpjjiFzjVKUY9dgfU7ubzue8vDOxn0NEt/A=";
  };

  vendorHash = "sha256-yhwokKjwDe99uuTlRtyoX4FeR1/RZEu7J0PMdAVrows=";

  subPackages = [ "cmd/bv" ];

  doCheck = false;

  meta = {
    description = "TUI for browsing and managing beads issue tracker";
    homepage = "https://github.com/Dicklesworthstone/beads_viewer";
    license = lib.licenses.mit;
    mainProgram = "bv";
  };
}
