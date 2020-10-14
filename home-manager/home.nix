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
}
