{ system }:
{
  inherit system;

  config = {
    allowUnfree = true;
    allowBroken = false;
    allowInsecure = false;
  };

  overlays = [
    # Add custom overlays here
  ];
}
