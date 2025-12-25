{ username, ... }:

{
  imports = [
    ../../../modules/nixos/base.nix
    ../../../modules/nixos/vm.nix
    ../../../modules/nixos/nfs-synology.nix
  ];

  networking.hostName = "base-vm";

  nfs-synology = {
    enable = true;
    mounts = [ "backups" ];
  };

  system.stateVersion = "25.05";
}
