{ pkgs, ... }:
{
  # Used for backwards compatibility, please read the changelog before changing
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";

  # System-wide packages
  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  # Machine-specific homebrew casks
  homebrew.casks = [
    "finicky"
  ];
}
