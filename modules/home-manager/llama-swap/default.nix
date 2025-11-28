{ config, pkgs, lib, ... }:

let
  cfg = config.services.llama-swap;
  llamaServerPath = "${cfg.llamaCppPackage}/bin/llama-server";
in
{
  options.services.llama-swap = {
    enable = lib.mkEnableOption "llama-swap LLM model management proxy";

    llamaCppPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llama-cpp;
      defaultText = lib.literalExpression "pkgs.llama-cpp";
      description = "The llama.cpp package to use (e.g., pkgs.llama-cpp-rocm for ROCm support).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create XDG directories
    home.file.".local/share/mymodels/.keep".text = "";
    home.file.".local/state/llama-swap/.keep".text = "";

    # Deploy llama-swap config with home directory and llama-server path substitution
    xdg.configFile."llama-swap/config.yml".text =
      builtins.replaceStrings
        ["\${HOME}" "llama-server"]
        [config.home.homeDirectory llamaServerPath]
        (builtins.readFile ./config.yml);

    # macOS: launchd agent
    launchd.agents.llama-swap = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.llama-swap}/bin/llama-swap"
          "-config"
          "${config.xdg.configHome}/llama-swap/config.yml"
          "--watch-config"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/.local/state/llama-swap/stdout.log";
        StandardErrorPath = "${config.home.homeDirectory}/.local/state/llama-swap/stderr.log";
      };
    };

    # Linux: systemd user service
    systemd.user.services.llama-swap = lib.mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "llama-swap LLM model management proxy";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.llama-swap}/bin/llama-swap -config ${config.xdg.configHome}/llama-swap/config.yml --watch-config";
        Restart = "always";
        RestartSec = 3;
        StandardOutput = "append:${config.home.homeDirectory}/.local/state/llama-swap/stdout.log";
        StandardError = "append:${config.home.homeDirectory}/.local/state/llama-swap/stderr.log";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
