{ config, username, ... }:

let
  repoRoot = ../../..;
in
{
  imports = [
    ../../../modules/nixos/base.nix
    ../../../modules/nixos/vm.nix
    ../../../modules/nixos/nfs-synology.nix
    ../../../modules/nixos/secrets.nix
    ../../../modules/nixos/jellyfin.nix
    ../../../modules/nixos/jellarr-secrets.nix
  ];

  networking.hostName = "imladris";

  # Docker
  virtualisation.docker.enable = true;

  # User config
  users.users.${username} = {
    extraGroups = [ "docker" ];
    initialHashedPassword = "$6$q2DwGVH4HSuss40a$9pTOHZ1vJ7gimEdnNflMuM/YyfY76LSDE1cBZVS4bb43fsHHoumrb2TWUXhfXnEEFfmCyv3dtq5EYEn371Hi/0";
  };
  users.users.root.initialHashedPassword = "$6$YX.HgOCY1BnEhuRH$PpG4rOUxQKu7vztIYJTt//h3WoINZjXaGmeKORfBdecahjo.vEIxQCoE7Mx0.F3vnIBQ0PBXLbr7OXhsd8/7p.";

  # NFS mounts (backups and media, not models)
  nfs-synology = {
    enable = true;
    lazyMounts = [
      "backups"
      "media"
    ];
  };

  # NixOS-level secrets
  nixos-secrets = {
    enable = true;
    encrypted = "${repoRoot}/secrets/secrets.json.age";
  };

  # Jellyfin media server
  services.media-server.enable = true;

  # jellarr with auto-bootstrap
  services.jellarr = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
    environmentFile = "/run/secrets/jellarr.env";

    bootstrap = {
      enable = true;
      apiKeyFile = "/run/secrets/jellarr-api-key";
    };

    config = {
      version = 1;
      system = { };
      base_url = "http://localhost:8096";

      startup.completeStartupWizard = true;

      users = [
        {
          name = "qmx";
          passwordFile = "/run/secrets/jellarr-admin-password";
          policy.isAdministrator = true;
        }
      ];

      library.virtualFolders = [
        {
          name = "Movies";
          collectionType = "movies";
          libraryOptions.pathInfos = [ { path = "/mnt/media/Movies"; } ];
        }
      ];
    };
  };

  system.stateVersion = "25.05";
}
