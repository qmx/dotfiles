{ pkgs
, ...
}:
with pkgs;
let
  ulidgen = rustPlatform.buildRustPackage rec {
    pname = "ulidgen";
    version = "0.1.0";

    src = fetchCrate {
      inherit pname;
      version = "0.1.0";
      sha256 = "0441sx02hq5nf2jldnhb304rya0gfsvv43665bnfdbxjfh7iwpq7";
    };

    cargoSha256 = "1wjzxjicclny7r5vwhzq7scphrfi9lapdvxysbm5yr7jl274y4ry";

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Foundation
    ];

    doCheck = false;
  };


  myGh = pkgs.gitAndTools.gh.overrideAttrs (oldAttrs: rec {
    buildInputs = [ pkgs.installShellFiles ];
  });
  packages = [
    ctags
    exa
    fd
    myGh
    gitAndTools.delta
    git-crypt
    jq
    niv
    nixpkgs-fmt
    ripgrep
    tokei
    ulidgen
    xsv
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
  home.packages = packages;
  home.stateVersion = "20.03";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
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
      vim-jsx-pretty
      vim-nix
      vim-ruby
      vim-surround
      vim-terraform
      vim-toml
      vim-trailing-whitespace
      vim-unimpaired
      vim-yaml
      yats-vim
    ];
  };
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    secureSocket = false;
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

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
    '';
  };

  programs.gpg = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      git_status = {
        disabled = true;
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableNixDirenvIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
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
      path = "\$HOME/.zhistory";
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
      # nix
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi

      # gnupg
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

      if [[ -f $HOME/.asdf/asdf.sh ]]; then
        . $HOME/.asdf/asdf.sh
      fi
    '';
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
      PATH = "$HOME/bin:$PATH";
    };
  };
}
