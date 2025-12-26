{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.useEreborCache = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to use erebor as a binary cache substituter";
  };

  config = {
    # Timezone
    time.timeZone = "America/New_York";

    # Nix settings
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    } // lib.optionalAttrs config.useEreborCache {
      # Use erebor binary caches (via Tailscale)
      substituters = [
        "http://erebor:8081" # ncps pull-through cache
        "http://erebor:8080/main" # attic push cache
      ];
      trusted-public-keys = [
        "erebor:OJso6qBW7GX9XGUMxcnxghDxRJCB8q9Chfskn586GQk=" # ncps
        "main:1hOkxeFysXATCl+nhdw48sjR1pG4JClk/YS9ONZXQOM=" # attic
      ];
    };

  # User setup
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    linger = true;
    openssh.authorizedKeys.keyFiles = [
      (builtins.fetchurl {
        url = "https://github.com/qmx.keys";
        sha256 = "0yz3qk6dwfx4jivm7ljd0p6rmqn4rdnbz1gwn7yh5ryy5mcjr2b1";
      })
    ];
  };

  # Core services
  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    # Disable TPM state encryption - broken on VMs, causes TPM_RC_INTEGRITY errors
    # See: https://github.com/tailscale/tailscale/issues/17653
    extraDaemonFlags = [
      "--encrypt-state=false"
      "--hardware-attestation=false"
    ];
  };
  services.timesyncd.enable = true;

  # Shell and packages
  programs.zsh.enable = true;
  programs.mosh.enable = true;
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    vim
    git
  ];
  };
}
