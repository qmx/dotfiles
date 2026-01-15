{
  system,
  pkgs-unstable ? null,
  pkgs-stable-pinned ? null,
}:
{
  inherit system;

  config = {
    allowUnfree = true;
    allowBroken = false;
    allowInsecure = false;
  };

  overlays = [
    (import ./pkgs { inherit pkgs-unstable pkgs-stable-pinned; })
  ];
}
