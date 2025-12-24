{
  config,
  lib,
  ...
}:

let
  cfg = config.services.media-server;
in
{
  options.services.media-server = {
    enable = lib.mkEnableOption "Jellyfin media server";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Wait for NFS media mount
    systemd.services.jellyfin = {
      after = [ "mnt-media.automount" ];
      wants = [ "mnt-media.automount" ];
    };

    users.users.jellyfin.extraGroups = [
      "render"
      "video"
    ];
  };
}
