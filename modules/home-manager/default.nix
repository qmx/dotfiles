{
  pkgs,
  pkgs-stable,
  lib,
  opencode,
  beads,
  ...
}:
{
  imports = [
    ./llama-swap
    ./opencode
    ./homebridge
  ];

  # Personal git configuration
  programs.git.settings = {
    user = {
      name = "Doug Campos";
      email = "qmx@qmx.me";
    };
  };

  # Personal packages
  home.packages =
    (with pkgs; [
      # Development tools
      cmake
      automake
      m4
      pkgs-stable.git-crypt

      # Media and utilities
      ffmpeg
      sqlite
      exiftool
      yt-dlp
      tesseract
      qemu

      # Yubikey tools
      yubikey-manager
      yubikey-personalization

      # LLM tools
      llama-cpp
      llama-swap
      claude-code-router

      # Beads tools
      beads-viewer
    ])
    ++ [
      opencode
      beads
    ];

  # Personal environment variables
  programs.zsh.sessionVariables = {
    HOMEBREW_NO_GITHUB_API = "1";
  };

  # Personal shell additions
  programs.zsh.initContent = ''
    # Homebrew-installed tools (chruby)
    if [ -f /opt/homebrew/opt/chruby/share/chruby/chruby.sh ]; then
      source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
      source /opt/homebrew/opt/chruby/share/chruby/auto.sh
    fi

    # Rancher Desktop
    export PATH="/Users/qmx/.rd/bin:$PATH"

    # Cargo/Rust tools
    export PATH="$HOME/.cargo/bin:$PATH"

    # Local bin
    export PATH="$HOME/.local/bin:$PATH"
  '';
}
