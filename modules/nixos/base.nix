{
  pkgs,
  username,
  ...
}:

{
  imports = [ ../nix-cache.nix ];
  time.timeZone = "America/New_York";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

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

  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    extraDaemonFlags = [
      "--encrypt-state=false"
      "--hardware-attestation=false"
    ];
  };
  services.timesyncd.enable = true;

  programs.zsh.enable = true;
  programs.mosh.enable = true;
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    vim
    git
  ];
}
