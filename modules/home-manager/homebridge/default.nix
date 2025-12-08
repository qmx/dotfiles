{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homebridgeNix;

  # Generate the config.json file from Nix options
  configFile = pkgs.writeText "config.json" (builtins.toJSON cfg.config);

  # Create a package that includes homebridge and all plugins
  homebridgeWithPlugins =
    if cfg.plugins == [ ] then
      cfg.package
    else
      pkgs.buildEnv {
        name = "homebridge-with-plugins";
        paths = [ cfg.package ] ++ cfg.plugins;
        pathsToLink = [ "/lib/node_modules" ];
      };

in
{
  options.services.homebridgeNix = {
    enable = mkEnableOption "Homebridge HomeKit support server";

    package = mkOption {
      type = types.package;
      default = pkgs.homebridge;
      defaultText = literalExpression "pkgs.homebridge";
      description = "The homebridge package to use.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.local/share/homebridge";
      description = "The directory where homebridge stores its data.";
    };

    config = mkOption {
      type = types.attrs;
      default = {
        bridge = {
          name = "Homebridge";
          username = "CC:22:3D:E3:CE:30";
          port = 51826;
          pin = "031-45-154";
          advertiser = "bonjour";
        };
        accessories = [ ];
        platforms = [ ];
      };
      example = literalExpression ''
        {
          bridge = {
            name = "My Homebridge";
            username = "AA:BB:CC:DD:EE:FF";
            port = 51826;
            pin = "123-45-678";
          };
          platforms = [
            {
              platform = "Camera-ffmpeg";
              cameras = [ ];
            }
          ];
        }
      '';
      description = ''
        Configuration for homebridge. This will be converted to JSON and
        written to config.json in the data directory.
      '';
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression "[ pkgs.homebridge-camera-ffmpeg ]";
      description = ''
        List of homebridge plugin packages to install.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Make packages available
    home.packages = [ cfg.package ];

    # Create the systemd user service
    systemd.user.services.homebridgeNix = {
      Unit = {
        Description = "Homebridge - HomeKit support for the impatient";
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        WorkingDirectory = cfg.dataDir;
        Environment = [
          "HOME=${config.home.homeDirectory}"
          "NODE_PATH=${homebridgeWithPlugins}/lib/node_modules"
        ];
        ExecStartPre = pkgs.writeShellScript "homebridge-pre-start" ''
          mkdir -p ${cfg.dataDir}/{persist,accessories}
          cp ${configFile} ${cfg.dataDir}/config.json
          chmod 750 ${cfg.dataDir}
          chmod 640 ${cfg.dataDir}/config.json
        '';
        ExecStart = "${homebridgeWithPlugins}/bin/homebridge -U ${cfg.dataDir}";
        Restart = "always";
        RestartSec = 3;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
