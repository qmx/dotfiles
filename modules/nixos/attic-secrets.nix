{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.attic;
in
{
  config = lib.mkIf cfg.enable {
    # Run after decryptSecrets (from modules/nixos/secrets.nix)
    system.activationScripts.atticSecrets = lib.stringAfter [ "decryptSecrets" ] ''
      if [ -f /run/secrets/data.json ]; then
        # Extract base64-encoded RSA key for JWT signing
        TOKEN=$(${pkgs.jq}/bin/jq -r '.atticServerToken' /run/secrets/data.json)

        # Create environment file for atticd
        echo "ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=$TOKEN" > /run/secrets/attic.env
        chown atticd:atticd /run/secrets/attic.env
        chmod 400 /run/secrets/attic.env
      fi
    '';
  };
}
