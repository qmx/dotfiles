{
  config,
  lib,
  ...
}:

let
  cfg = config.services.attic;
in
{
  imports = [ ./attic-secrets.nix ];

  options.services.attic = {
    enable = lib.mkEnableOption "Attic binary cache server";

    storagePath = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/nix-cache";
      description = "Path to NFS-mounted storage for cache data and SQLite DB";
    };

    listen = lib.mkOption {
      type = lib.types.str;
      default = "[::]:8080";
      description = "Address and port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    # Use the built-in NixOS atticd module
    services.atticd = {
      enable = true;

      # Environment file with JWT secret (created by attic-secrets.nix)
      environmentFile = "/run/secrets/attic.env";

      settings = {
        listen = cfg.listen;

        # SQLite database on NFS
        database.url = "sqlite://${cfg.storagePath}/attic.db?mode=rwc";

        # Local storage backend on NFS
        storage = {
          type = "local";
          path = "${cfg.storagePath}/store";
        };

        # Chunking settings (defaults from attic docs)
        chunking = {
          nar-size-threshold = 65536; # 64 KiB
          min-size = 16384; # 16 KiB
          avg-size = 65536; # 64 KiB
          max-size = 262144; # 256 KiB
        };

        # Compression
        compression.type = "zstd";

        # Garbage collection
        garbage-collection.interval = "12 hours";
      };
    };

    # Ensure NFS is mounted before atticd starts, and create storage directory
    systemd.services.atticd = {
      after = [ "mnt-nix\\x2dcache.mount" ];
      requires = [ "mnt-nix\\x2dcache.mount" ];
      serviceConfig.ExecStartPre = [
        "+/run/current-system/sw/bin/mkdir -p ${cfg.storagePath}/store"
      ];
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ 8080 ];
  };
}
