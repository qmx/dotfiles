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
    "solargraph.enable" = false;
    "solargraph.promptDownload" = false;
    "solargraph.transport" = "stdio";
  };
  workCocSettings = {
    languageserver = {
      sorbet = {
        command = "bundle";
        args = [ "exec" "srb" "tc" "--lsp" ];
        filetypes = [ "ruby" ];
      };
    };
  };
  finalCocSettings = lib.attrsets.recursiveUpdate cocSettings workCocSettings;
in
{
  imports = [
    ./default.nix
  ];
  home.file = {
    ".config/nvim/coc-settings.json".text = builtins.toJSON finalCocSettings;
  };
}
