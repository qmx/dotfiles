{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  # User setup
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [
      (builtins.fetchurl {
        url = "https://github.com/qmx.keys";
        sha256 = "0yz3qk6dwfx4jivm7ljd0p6rmqn4rdnbz1gwn7yh5ryy5mcjr2b1";
      })
    ];
  };

  # Core services
  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.timesyncd.enable = true;

  # Shell and packages
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
