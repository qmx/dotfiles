{ config, lib, ... }:

let
  cfg = config.nfs-synology;
  shareConfigs = {
    models = {
      device = "192.168.1.200:/volume1/models";
      mountPoint = "/mnt/models";
    };
    backups = {
      device = "192.168.1.200:/volume1/backups";
      mountPoint = "/mnt/backups";
    };
    media = {
      device = "192.168.1.200:/volume1/media";
      mountPoint = "/mnt/media";
    };
  };
in
{
  options.nfs-synology = {
    enable = lib.mkEnableOption "Synology NFS mounts";
    mounts = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "models"
        "backups"
        "media"
      ]);
      default = [ ];
      description = "Which Synology shares to mount";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems = lib.listToAttrs (
      map (name: {
        name = shareConfigs.${name}.mountPoint;
        value = {
          device = shareConfigs.${name}.device;
          fsType = "nfs";
          options = [
            "x-systemd.automount"
            "noauto"
            "x-systemd.idle-timeout=600"
          ];
        };
      }) cfg.mounts
    );
  };
}
