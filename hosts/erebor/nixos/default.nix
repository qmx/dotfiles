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
    ../../../modules/nixos/attic.nix
    ../../../modules/nixos/ncps.nix
  ];

  networking.hostName = "erebor";

  # Don't use ourselves as a cache substituter
  useEreborCache = false;

  # Passwords (same as other VMs - generate with: mkpasswd -m sha-512)
  users.users.${username}.initialHashedPassword =
    "$6$q2DwGVH4HSuss40a$9pTOHZ1vJ7gimEdnNflMuM/YyfY76LSDE1cBZVS4bb43fsHHoumrb2TWUXhfXnEEFfmCyv3dtq5EYEn371Hi/0";
  users.users.root.initialHashedPassword =
    "$6$YX.HgOCY1BnEhuRH$PpG4rOUxQKu7vztIYJTt//h3WoINZjXaGmeKORfBdecahjo.vEIxQCoE7Mx0.F3vnIBQ0PBXLbr7OXhsd8/7p.";

  # NFS mounts - only the cache
  nfs-synology = {
    enable = true;
    mounts = [ "nix-cache" ];
  };

  # NixOS-level secrets
  nixos-secrets = {
    enable = true;
    encrypted = "${repoRoot}/secrets/secrets.json.age";
  };

  # Attic binary cache server (port 8080) - for custom packages
  services.attic = {
    enable = true;
    storagePath = "/mnt/nix-cache";
  };

  # ncps pull-through cache (port 8081) - for upstream packages
  services.nix-cache-proxy = {
    enable = true;
    storagePath = "/mnt/nix-cache";
  };

  # Dynamic swap management - creates/removes swap files as needed
  services.swapspace.enable = true;

  system.stateVersion = "25.05";
}
