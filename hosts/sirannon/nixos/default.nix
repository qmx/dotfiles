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

  # NFS mounts - apps removed, Gitea uses local storage
  nfs-synology = {
    enable = true;
    lazyMounts = [
      "models"
      "backups"
      "media"
    ];
  };

  # Gitea service with LOCAL storage (avoids NFS locking issues)
  services.gitea = {
    enable = true;
    stateDir = "/var/lib/gitea";
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

  # Daily backup to NFS
  systemd.services.gitea-backup = {
    description = "Backup Gitea to NFS";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.rsync}/bin/rsync -a --delete /var/lib/gitea/ /mnt/backups/gitea/";
    };
    wants = [ "mnt-backups.automount" ];
    after = [ "mnt-backups.automount" ];
  };

  systemd.timers.gitea-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

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
