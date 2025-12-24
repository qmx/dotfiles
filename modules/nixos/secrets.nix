{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos-secrets;
in
{
  options.nixos-secrets = {
    enable = lib.mkEnableOption "NixOS-level age secrets";

    encrypted = lib.mkOption {
      type = lib.types.path;
      description = "Path to age-encrypted secrets JSON file";
    };

    identityFile = lib.mkOption {
      type = lib.types.str;
      default = "/root/.config/age/keys.txt";
      description = "Path to age identity file";
    };
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.decryptSecrets = lib.stringAfter [ "users" "groups" ] ''
      echo "Decrypting NixOS secrets..."
      mkdir -p /run/secrets
      chmod 700 /run/secrets

      if [ -f "${cfg.identityFile}" ]; then
        ${pkgs.age}/bin/age --decrypt \
          -i "${cfg.identityFile}" \
          -o /run/secrets/data.json \
          "${cfg.encrypted}"
        chmod 600 /run/secrets/data.json
      else
        echo "WARNING: Age identity not found at ${cfg.identityFile}"
        echo "Secrets not decrypted. Copy key from 1Password."
      fi
    '';
  };
}
