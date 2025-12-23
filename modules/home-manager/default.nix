{
  config,
  pkgs,
  pkgs-stable,
  lib,
  opencode,
  duckduckgo-mcp-server,
  ...
}:
{
  imports = [
    ./llama-swap
    ./opencode
    ./homebridge
    ./claude-code-router
  ];

  # Try - experiment directory manager
  programs.try.enable = true;

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

      # LLM tools (only on hosts with llama-swap enabled)
      claude-code-router

      # Beads tools
      beads-viewer
    ])
    ++ [
      opencode
      duckduckgo-mcp-server
    ]
    ++ lib.optionals config.services.llama-swap.enable [
      pkgs.llama-cpp
      pkgs.llama-swap
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Claude Code sandbox dependencies
      pkgs.socat
      pkgs.bubblewrap
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
