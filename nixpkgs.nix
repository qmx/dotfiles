{ system, pkgs-unstable ? null }:
{
  inherit system;

  config = {
    allowUnfree = true;
    allowBroken = false;
    allowInsecure = false;
  };

  overlays = [
    (import ./pkgs { inherit pkgs-unstable; })
  ];
}
