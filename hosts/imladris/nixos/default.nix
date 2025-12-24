{ username, ... }:

{
  imports = [
    ../../../modules/nixos/base.nix
    ../../../modules/nixos/vm.nix
    ../../../modules/nixos/nfs-synology.nix
  ];

  networking.hostName = "imladris";

  # Passwords (from secrets/secrets.json.age)
  users.users.${username}.initialHashedPassword = "$6$q2DwGVH4HSuss40a$9pTOHZ1vJ7gimEdnNflMuM/YyfY76LSDE1cBZVS4bb43fsHHoumrb2TWUXhfXnEEFfmCyv3dtq5EYEn371Hi/0";
  users.users.root.initialHashedPassword = "$6$YX.HgOCY1BnEhuRH$PpG4rOUxQKu7vztIYJTt//h3WoINZjXaGmeKORfBdecahjo.vEIxQCoE7Mx0.F3vnIBQ0PBXLbr7OXhsd8/7p.";

  # NFS mounts (backups and media, not models)
  nfs-synology = {
    enable = true;
    mounts = [
      "backups"
      "media"
    ];
  };

  system.stateVersion = "25.05";
}
