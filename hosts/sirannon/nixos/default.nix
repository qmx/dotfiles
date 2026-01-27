{
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/base.nix
    ../../../modules/nixos/nfs-synology.nix
    ../../../modules/nixos/yubikey.nix
  ];

  # Raspberry Pi 4 boot
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "sirannon";

  # NFS mounts
  nfs-synology = {
    enable = true;
    lazyMounts = [
      "models"
      "backups"
      "media"
    ];
    persistentMounts = [ "apps" ];
  };

  # Gitea user/group with fixed uid/gid to match NFS data ownership
  users.users.gitea = {
    isSystemUser = true;
    uid = 1025;
    group = "gitea";
  };
  users.groups.gitea.gid = 1025;

  # Gitea service
  services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/mnt/apps/gitea";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "sirannon";
        ROOT_URL = "http://sirannon:3000/";
        HTTP_ADDR = "0.0.0.0";
        HTTP_PORT = 3000;
        SSH_PORT = 2222;
        START_SSH_SERVER = true;
      };
    };
  };

  # Firewall - allow Gitea web and SSH
  networking.firewall.allowedTCPPorts = [ 3000 2222 ];

  # WiFi
  networking.wireless = {
    enable = true;
    networks."qmx".psk = "tis8bok5oov1";
  };

  # Extra packages (beyond base.nix)
  environment.systemPackages = with pkgs; [
    neovim
    raspberrypi-eeprom
    tmux
    wget
  ];

  # NixOS state version
  system.stateVersion = "25.05";
}
