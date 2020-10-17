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
    bat
    exa
    direnv
    fd
    gitAndTools.hub
    gnupg
    jq
    nixpkgs-fmt
    ripgrep
    starship
    zoxide
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
    extraConfig = builtins.readFile ./extraConfig.vim;
    plugins = with pkgs.vimPlugins; [
      editorconfig-vim
      emmet-vim
      fzf-vim
      nerdcommenter
      nerdtree
      nord-vim
      tagbar
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
      vim-toml
      vim-trailing-whitespace
      vim-yaml
    ];
  };
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    escapeTime = 1;
    historyLimit = 20000;
    keyMode = "vi";
    shortcut = "a";
    baseIndex = 1;
    resizeAmount = 5;
    terminal = "screen-256color";
    extraConfig = ''
      set -g renumber-windows on
      bind | split-window -h
      bind - split-window -v
    '';
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    defaultKeymap = "emacs";
    history = {
      extended = true;
      size = 50000;
      save = 50000;
      path = ".zhistory";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };
    initExtraBeforeCompInit = ''
      setopt complete_in_word
      setopt extended_glob
      setopt hist_fcntl_lock
      setopt hist_verify
    '';
    initExtra = ''
      if ! pgrep -x -u "$USER" gpg-agent >/dev/null 2>&1; then
              gpg-connect-agent /bye >/dev/null 2>&1
      fi

      gpg-connect-agent updatestartuptty /bye >/dev/null

      export GPG_TTY=$(tty)

      if [[ -z "$SSH_AUTH_SOCK" ]] || [[ "$SSH_AUTH_SOCK" == *"apple.launchd"* ]]; then
              SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
              export SSH_AUTH_SOCK
      fi

      # dev
      if [[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]]; then
        source /opt/dev/dev.sh
      fi

      # nix
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi

      eval $(cat ~/.nix-profile/share/DIR_COLORS)
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"
    '';
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
      PATH = "$HOME/bin:$PATH";
    };
  };
}
