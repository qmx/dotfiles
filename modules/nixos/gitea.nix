{
  config,
  lib,
  pkgs,
  sops-nix,
  sopsSecretsFile,
  ...
}:

let
  cfg = config.services.gitea-container;
in
{
  imports = [ sops-nix.nixosModules.sops ];

  options.services.gitea-container = {
    enable = lib.mkEnableOption "Gitea in container with Tailscale identity";

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/apps/gitea";
      description = "Base directory for Gitea data";
    };

    tailscaleHostname = lib.mkOption {
      type = lib.types.str;
      default = "gitea";
      description = "Hostname on tailnet";
    };

    externalInterface = lib.mkOption {
      type = lib.types.str;
      description = "Network interface for outbound NAT";
    };
  };

  config = lib.mkIf cfg.enable {
    # sops configuration
    sops = {
      defaultSopsFile = sopsSecretsFile;
      age.keyFile = "/root/.config/age/keys.txt";
      secrets."gitea/tailscaleKey" = { };
    };

    # NAT for container internet access
    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-gitea" ];
      externalInterface = cfg.externalInterface;
    };

    containers.gitea = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";

      bindMounts = {
        "${cfg.dataDir}" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
        "/run/secrets/tailscale-authkey" = {
          hostPath = config.sops.secrets."gitea/tailscaleKey".path;
          isReadOnly = true;
        };
      };

      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          system.stateVersion = "25.05";

          services.tailscale = {
            enable = true;
            authKeyFile = "/run/secrets/tailscale-authkey";
            extraUpFlags = [ "--hostname=${cfg.tailscaleHostname}" ];
          };

          services.gitea = {
            enable = true;
            stateDir = "${cfg.dataDir}/state";

            database.type = "sqlite3";

            settings = {
              server = {
                DOMAIN = cfg.tailscaleHostname;
                ROOT_URL = "https://${cfg.tailscaleHostname}/";
                HTTP_ADDR = "127.0.0.1";
                HTTP_PORT = 3000;
                SSH_DOMAIN = cfg.tailscaleHostname;
                SSH_PORT = 22;
                START_SSH_SERVER = true;
              };
              repository.ROOT = lib.mkForce "${cfg.dataDir}/repositories";
              service.DISABLE_REGISTRATION = true;
            };

            lfs = {
              enable = true;
              contentDir = "${cfg.dataDir}/lfs";
            };
          };

          # Wait for Tailscale to connect, then enable HTTPS proxy
          systemd.services.tailscale-serve = {
            description = "Tailscale HTTPS proxy for Gitea";
            after = [
              "tailscaled.service"
              "gitea.service"
            ];
            requires = [ "tailscaled.service" ];
            wants = [ "gitea.service" ];
            wantedBy = [ "multi-user.target" ];
            path = [
              pkgs.tailscale
              pkgs.jq
            ];

            script = ''
              # Wait for Tailscale to be online
              while ! tailscale status --json 2>/dev/null | jq -e '.Self.Online' >/dev/null; do
                echo "Waiting for Tailscale..."
                sleep 2
              done
              tailscale serve --bg 3000
            '';

            preStop = ''
              tailscale serve off || true
            '';

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
          };

          networking.firewall.allowedTCPPorts = [ 22 ];
        };
    };

    # Ensure NFS ready before container
    systemd.services."container@gitea" = {
      after = [ "apps.mount" ];
      requires = [ "apps.mount" ];
    };
  };
}
