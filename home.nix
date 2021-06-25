{ pkgs
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
in
{
  imports = [
    ./default.nix
  ];
  home.file = {
    ".config/nvim/coc-settings.json".text = builtins.toJSON cocSettings;
  };
}
