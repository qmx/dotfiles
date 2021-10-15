{ config
, pkgs
, lib
, ...
}:
let
  vsCodeConfigDir = "Code";
  vsCodeUserDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/${vsCodeConfigDir}/User"
    else
      "${config.xdg.configHome}/${vsCodeConfigDir}/User";

  vsCodeConfigFilePath = "${vsCodeUserDir}/settings.json";
  vsCodeSettings = {
    "editor.fontSize" = 16;
    "terminal.integrated.fontSize" = 16;
  };
  alacrittyConfigFilePath = "${config.xdg.configHome}/alacritty/alacritty.yml";
in
{
  imports = [
    ./default.nix
  ];

  home.file = {
    "${vsCodeConfigFilePath}".text = builtins.toJSON vsCodeSettings;
    "${alacrittyConfigFilePath}".text = builtins.readFile ./alacritty.yml;
  };
}
