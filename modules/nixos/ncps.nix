{
  config,
  lib,
  ...
}:

let
  cfg = config.services.nix-cache-proxy;
in
{
  options.services.nix-cache-proxy = {
    enable = lib.mkEnableOption "ncps pull-through cache proxy";

    storagePath = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/nix-cache";
      description = "Path to NFS-mounted storage for cached packages";
    };

    maxSize = lib.mkOption {
      type = lib.types.str;
      default = "500G";
      description = "Maximum cache size (LRU eviction)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ncps = {
      enable = true;

      cache = {
        hostName = "erebor";
        dataPath = "${cfg.storagePath}/ncps";
        databaseURL = "sqlite://${cfg.storagePath}/ncps/ncps.db";
        maxSize = cfg.maxSize;
        lru.schedule = "0 23 * * *"; # 11pm daily cleanup
      };

      upstream = {
        caches = [ "https://cache.nixos.org" ];
        publicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      };

      server.addr = "[::]:${toString cfg.port}";
      prometheus.enable = true;
    };

    # Ensure NFS is mounted before ncps starts
    systemd.services.ncps = {
      after = [ "mnt-nix\\x2dcache.mount" ];
      requires = [ "mnt-nix\\x2dcache.mount" ];
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
