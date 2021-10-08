{ writeScriptBin, pkgs }:
with pkgs;
let
  myYarn = yarn.overrideAttrs (oldAttrs: rec {
    buildInputs = [ nodejs-14_x ];
  });
  wrapped = writeScriptBin "nyarn" ''
    ${myYarn}/bin/yarn "$@"
  '';
in
symlinkJoin {
  name = "nyarn";
  paths = [
    wrapped
  ];
}
