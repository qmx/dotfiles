{
  config,
  lib,
  pkgs,
  sops-nix,
  sopsSecretsFile,
  ...
}:

let
  cfg = config.services.gitea-vm;
in
{
  imports = [ sops-nix.nixosModules.sops ];

  options.services.gitea-vm = {
    enable = lib.mkEnableOption "Gitea microVM";
    tailscaleHostname = lib.mkOption {
      type = lib.types.str;
      default = "gitea";
    };
  };

  config = lib.mkIf cfg.enable {
    # Host-side sops secret
    sops = {
      defaultSopsFile = sopsSecretsFile;
      age.keyFile = "/root/.config/age/keys.txt";
      secrets."gitea/tailscaleKey" = { };
    };

    microvm.vms.gitea = {
      inherit pkgs;

      config =
        { ... }:
        {
          microvm = {
            hypervisor = "qemu"; # Best aarch64 support
            vcpu = 2;
            mem = 512;

            # User-mode networking - outbound only, enough for Tailscale
            interfaces = [
              {
                type = "user";
                id = "usernet";
              }
            ];

            # Share data and secrets with host
            shares = [
              {
                source = "/apps/gitea";
                mountPoint = "/var/lib/gitea";
                tag = "gitea-data";
                proto = "virtiofs";
              }
              {
                source = "/run/secrets/gitea";
                mountPoint = "/run/secrets";
                tag = "secrets";
                proto = "virtiofs";
              }
            ];
          };

          networking.hostName = cfg.tailscaleHostname;

          # Tailscale for all networking
          services.tailscale = {
            enable = true;
            authKeyFile = "/run/secrets/tailscaleKey";
          };

          # Gitea service
          services.gitea = {
            enable = true;
            stateDir = "/var/lib/gitea";
            lfs.enable = true;
            settings = {
              server = {
                DOMAIN = cfg.tailscaleHostname;
                ROOT_URL = "https://${cfg.tailscaleHostname}/";
                HTTP_ADDR = "127.0.0.1";
                HTTP_PORT = 3000;
              };
              service.DISABLE_REGISTRATION = true;
              repository.ROOT = "/var/lib/gitea/repositories";
            };
          };

          # Tailscale Serve exposes gitea on HTTPS
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
          system.stateVersion = "24.11";
        };
    };

    # Ensure NFS is mounted before VM starts
    systemd.services."microvm@gitea" = {
      after = [ "apps.mount" ];
      requires = [ "apps.mount" ];
    };
  };
}
