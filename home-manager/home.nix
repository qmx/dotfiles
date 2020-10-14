{ config, pkgs, ... }:
let
  LS_COLORS = pkgs.fetchgit {
    url = "https://github.com/trapd00r/LS_COLORS";
    rev = "6fb72eecdcb533637f5a04ac635aa666b736cf50";
    sha256 = "0czqgizxq7ckmqw9xbjik7i1dfwgc1ci8fvp1fsddb35qrqi857a";
  };
  ls-colors = pkgs.runCommand "ls-colors" { } ''
    mkdir -p $out/bin $out/share
    ${pkgs.coreutils}/bin/dircolors -b ${LS_COLORS}/LS_COLORS > $out/share/DIR_COLORS
  '';
  localPackages = [ ls-colors ];
  packages = with pkgs; [
    fd
    gitAndTools.hub
    jq
    nixpkgs-fmt
    ripgrep
  ];
  tpope.vim-rails = pkgs.vimUtils.buildVimPlugin {
    name = "vim-rails";
    src = pkgs.fetchFromGitHub {
      owner = "tpope";
      repo = "vim-rails";
      rev = "2c42236cf38c0842dd490095ffd6b1540cad2e29";
      sha256 = "0nhf4qd7dchrzjv2ijcddav72qb121c9jkkk06agsv23l9rb31pv";
    };
  };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = "~/dev/dotfiles/home-manager/home.nix";
  home.packages = localPackages ++ packages;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.htop.enable = true;
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      editorconfig-vim
      emmet-vim
      fzf-vim
      nerdcommenter
      nerdtree
      nord-vim
      tpope.vim-rails
      typescript-vim
      vim-airline
      vim-airline-themes
      vim-endwise
      vim-fugitive
      vim-gitgutter
      vim-nix
      vim-ruby
      vim-surround
      vim-terraform
    ];
  };
}
