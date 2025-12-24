{
  username,
  homeDirectory,
  pkgs,
  ...
}:
{
  # gnupg provides gpgconf used in zsh init
  home.packages = [ pkgs.gnupg ];
  # linux-yubikey role: YubiKey SSH authentication support for Linux systems
  #
  # This role configures:
  # - SSH agent to prefer local YubiKey via gpg-agent
  # - Fallback to forwarded SSH agent when YubiKey unavailable
  # - Udev rules for USB device permissions (requires manual installation)
  #
  # System Requirements:
  # ==================
  # 1. User must be in 'plugdev' group (Debian default for console users)
  #
  # 2. System packages (informational - likely already installed):
  #    - pcscd, libccid (smart card daemon and CCID driver)
  #    - libyubikey-udev (basic udev rules, though incomplete for SSH)
  #
  # 3. Additional udev rules for SSH access:
  #    The libyubikey-udev package only sets ENV{ID_SECURITY_TOKEN}="1"
  #    which enables TAG+="uaccess", but that only works for local console
  #    sessions. For SSH sessions, we need GROUP-based permissions.
  #
  #    The devShell will check if the udev rules are installed and provide
  #    instructions if needed. See: nix develop

  # YubiKey SSH agent configuration
  programs.zsh.initContent = ''
    # YubiKey SSH agent: prefer local YubiKey, fallback to forwarded agent

    # Save forwarded agent if present
    FORWARDED_AGENT=""
    if [[ -n "$SSH_AUTH_SOCK" ]] && [[ "$SSH_AUTH_SOCK" != *"gnupg"* ]]; then
        FORWARDED_AGENT="$SSH_AUTH_SOCK"
    fi

    # Try gpg-agent first (for local YubiKey)
    GPG_AGENT_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export SSH_AUTH_SOCK="$GPG_AGENT_SOCK"

    # Check if gpg-agent has keys available
    if ! ssh-add -l >/dev/null 2>&1; then
        # gpg-agent has no keys (YubiKey not available), use forwarded agent if available
        if [[ -n "$FORWARDED_AGENT" ]]; then
            export SSH_AUTH_SOCK="$FORWARDED_AGENT"
        fi
    fi
  '';

  # Make YubiKey udev rules available for manual installation
  home.file.".config/yubikey-udev/70-yubikey-usb.rules".source = ../udev/70-yubikey-usb.rules;
}
