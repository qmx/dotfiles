{ config
, pkgs
, lib
, ...
}:
let
  cocSettings = {
    languageserver = {
      nix = {
        command = "rnix-lsp";
        filetypes = [ "nix" ];
      };
      terraform = {
        command = "terraform-lsp";
        filetypes = [ "terraform" ];
      };
    };
    "coc.preferences.formatOnSaveFiletypes" = [
      "css"
      "markdown"
      "typescript"
      "typescriptreact"
      "javascript"
      "html"
    ];
    "solargraph.promptDownload" = false;
    "solargraph.checkGemVersion" = false;
    "solargraph.transport" = "stdio";
  };
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
in
{
  imports = [
    ./default.nix
  ];

  home.file = {
    ".config/nvim/coc-settings.json".text = builtins.toJSON cocSettings;
    "${vsCodeConfigFilePath}".text = builtins.toJSON vsCodeSettings;
  };
}
