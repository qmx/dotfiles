{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.secrets;
  secretsDir = "${config.home.homeDirectory}/.secrets";
in
{
  options.secrets = {
    enable = lib.mkEnableOption "age-based secrets management";

    identity = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/age/keys.txt";
      description = "Path to age identity file for decryption";
    };

    encrypted = lib.mkOption {
      type = lib.types.path;
      description = "Path to age-encrypted secrets JSON file";
    };

    templates = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            template = lib.mkOption {
              type = lib.types.path;
              description = "Path to minijinja template file";
            };
            output = lib.mkOption {
              type = lib.types.str;
              description = "Output path for rendered template";
            };
            extraData = lib.mkOption {
              type = lib.types.listOf lib.types.path;
              default = [ ];
              description = "Additional JSON data files to merge (e.g., Nix-generated configs)";
            };
            mode = lib.mkOption {
              type = lib.types.str;
              default = "0600";
              description = "File permissions for output";
            };
          };
        }
      );
      default = { };
      description = "Templates to render with decrypted secrets";
    };

    envFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to env file that zsh should source (if any)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.age
      pkgs.minijinja
    ];

    # Activation script to decrypt secrets and render templates
    home.activation.decryptSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create secrets directory
      run mkdir -p "${secretsDir}"
      run chmod 700 "${secretsDir}"

      # Decrypt secrets JSON
      if [ -f "${cfg.identity}" ]; then
        run ${pkgs.age}/bin/age --decrypt \
          -i "${cfg.identity}" \
          -o "${secretsDir}/data.json" \
          "${cfg.encrypted}"
        run chmod 600 "${secretsDir}/data.json"

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: tmpl:
            let
              extraDataArgs = lib.concatMapStringsSep " " (f: ''"${f}"'') tmpl.extraData;
            in
            ''
              # Render template: ${name}
              run mkdir -p "$(dirname "${tmpl.output}")"
              run ${pkgs.minijinja}/bin/minijinja-cli \
                --autoescape none \
                "${tmpl.template}" \
                "${secretsDir}/data.json" \
                ${extraDataArgs} \
                -o "${tmpl.output}"
              run chmod ${tmpl.mode} "${tmpl.output}"
            ''
          ) cfg.templates
        )}
      else
        echo "WARNING: Age identity not found at ${cfg.identity}, skipping secrets decryption"
      fi
    '';

    # Source env file in zsh if configured
    programs.zsh.initContent = lib.mkIf (cfg.envFile != null) ''
      # Source secrets env file if it exists
      [ -f "${cfg.envFile}" ] && source "${cfg.envFile}"
    '';
  };
}
