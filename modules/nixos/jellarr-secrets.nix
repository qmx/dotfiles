{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.jellarr;
in
{
  config = lib.mkIf cfg.enable {
    # Extend activation to extract jellarr secrets
    system.activationScripts.jellarrSecrets = lib.stringAfter [ "decryptSecrets" ] ''
      if [ -f /run/secrets/data.json ]; then
        API_KEY=$(${pkgs.jq}/bin/jq -r '.jellarr.apiKey' /run/secrets/data.json)

        # API key file for bootstrap
        echo "$API_KEY" > /run/secrets/jellarr-api-key
        chown jellyfin:jellyfin /run/secrets/jellarr-api-key
        chmod 400 /run/secrets/jellarr-api-key

        # Environment file for jellarr service
        echo "JELLARR_API_KEY=$API_KEY" > /run/secrets/jellarr.env
        chown jellyfin:jellyfin /run/secrets/jellarr.env
        chmod 400 /run/secrets/jellarr.env
      fi
    '';
  };
}
