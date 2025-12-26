{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.attic-client;
in
{
  options.services.attic-client = {
    enable = lib.mkEnableOption "Attic binary cache client";

    server = lib.mkOption {
      type = lib.types.str;
      default = "erebor";
      description = "Name of the Attic server";
    };

    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "http://erebor:8080";
      description = "URL of the Attic server";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install attic-client
    environment.systemPackages = [ pkgs.attic-client ];

    # Create config after secrets are decrypted
    system.activationScripts.atticClientConfig = lib.stringAfter [ "decryptSecrets" ] ''
      if [ -f /run/secrets/data.json ]; then
        TOKEN=$(${pkgs.jq}/bin/jq -r '.atticClientToken' /run/secrets/data.json)

        # Create system-wide attic config
        mkdir -p /etc/attic
        cat > /etc/attic/config.toml << EOF
[servers.${cfg.server}]
endpoint = "${cfg.endpoint}"
token = "$TOKEN"

[default]
server = "${cfg.server}"
EOF
        chmod 600 /etc/attic/config.toml
      fi
    '';

    # Set ATTIC_CONFIG_DIR so attic finds the system config
    environment.variables.ATTIC_CONFIG_DIR = "/etc/attic";
  };
}
