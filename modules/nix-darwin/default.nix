{ pkgs, username, ... }:
{
  # User account
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Primary user for homebrew and other user-specific features
  system.primaryUser = username;

  # Enable shells
  programs.zsh.enable = true;

  # Homebrew integration - personal apps
  homebrew = {
    casks = [
      # Personal GUI apps go here
    ];

    masApps = {
      # Add Mac App Store apps here
      # "App Name" = app_id;
    };
  };
}
