{ system }:
{
  inherit system;

  config = {
    allowUnfree = true;
    allowBroken = false;
    allowInsecure = false;
  };

  overlays = [
    (import ./pkgs)
  ];
}
