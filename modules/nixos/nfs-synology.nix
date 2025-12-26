{ config, lib, ... }:

let
  cfg = config.nfs-synology;
  allMountNames = [
    "models"
    "backups"
    "media"
    "nix-cache"
  ];
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
    nix-cache = {
      device = "192.168.1.200:/volume1/nix-cache";
      mountPoint = "/mnt/nix-cache";
    };
  };

  # Automount options (lazy mount with idle timeout)
  automountOptions = [
    "rw"
    "hard"
    "intr"
    "noauto"
    "nfsvers=4"
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"
  ];

  # Persistent mount options (mount at boot, stay mounted)
  persistentOptions = [
    "rw"
    "hard"
    "intr"
    "nfsvers=4"
  ];

  mkMount = name: persistent: {
    name = shareConfigs.${name}.mountPoint;
    value = {
      device = shareConfigs.${name}.device;
      fsType = "nfs";
      options = if persistent then persistentOptions else automountOptions;
    };
  };
in
{
  options.nfs-synology = {
    enable = lib.mkEnableOption "Synology NFS mounts";
    lazyMounts = lib.mkOption {
      type = lib.types.listOf (lib.types.enum allMountNames);
      default = [ ];
      description = "Shares to automount on first access and unmount after 10min idle";
    };
    persistentMounts = lib.mkOption {
      type = lib.types.listOf (lib.types.enum allMountNames);
      default = [ ];
      description = "Shares to mount at boot and keep mounted";
    };
  };

  config = lib.mkIf cfg.enable {
    # NFS client support
    boot.supportedFilesystems = [ "nfs" ];

    fileSystems = lib.listToAttrs (
      (map (name: mkMount name false) cfg.lazyMounts)
      ++ (map (name: mkMount name true) cfg.persistentMounts)
    );
  };
}
