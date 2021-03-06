{ pkgs
, ...
}:
with pkgs;
let
  ulidgen = callPackage ./tools/ulidgen.nix { };
  nrails = callPackage ./tools/nrails.nix { };
  nyarn = callPackage ./tools/nyarn.nix { };
  local_pg = callPackage ./tools/local_pg.nix { };

  packages = [
    ctags
    entr
    exa
    fd
    gh
    git-crypt
    jq
    jump
    local_pg
    mosh
    niv
    nixpkgs-fmt
    nodePackages.mermaid-cli
    nrails
    nyarn
    ripgrep
    rnix-lsp
    rust-analyzer-unwrapped
    tokei
    terraform-lsp
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

  home.file = {
    ".gitconfig-work".source = ./gitconfig-work;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.htop.enable = true;
  programs.neovim = {
    enable = true;
    extraConfig = builtins.readFile ./extraConfig.vim;
    withRuby = false;
    plugins = with pkgs.vimPlugins; [
      coc-emmet
      coc-explorer
      coc-fzf
      coc-json
      coc-nvim
      coc-rust-analyzer
      coc-solargraph
      coc-tsserver
      coc-prettier
      coc-yaml
      editorconfig-vim
      emmet-vim
      fzf-vim
      nerdcommenter
      nord-vim
      tagbar
      tpope.vim-rails
      typescript-vim
      vim-airline
      vim-airline-themes
      vim-endwise
      vim-fugitive
      vim-gitgutter
      vim-graphql
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
    shortcut = "b";
    baseIndex = 1;
    resizeAmount = 5;
    terminal = "screen-256color";
    extraConfig = ''
      set -g renumber-windows on

      bind r source-file ~/.tmux.conf \; display "Config Reloaded!"

      bind | split-window -h
      bind - split-window -v

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
    '';
    plugins = with pkgs.tmuxPlugins; [
      nord
    ];
  };

  programs.git = {
    userEmail = "qmx@qmx.me";
    userName = "Doug Campos";
    delta.enable = true;
    enable = true;
    aliases = {
      graph = "log --decorate --graph --all --oneline";
    };
    includes = [
      {
        condition = "gitdir:~/src/";
        path = "~/.gitconfig-work";
      }
    ];
    extraConfig = {
      diff.algorithm = "patience";
      gc.writeCommitGraph = "true";
      github.user = "qmx";
      merge.conflictstyle = "diff3";
      merge.tool = "nfugitive";
      mergetool.nfugitive.cmd = ''
        nvim -f -c "Gdiffvsplit!" "$MERGED"
      '';
      protocol.version = "2";
      pull.ff = "only";
    };
  };

  programs.gpg = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    extraOptionOverrides = {
      Include = "~/.spin/ssh/include";
    };
    matchBlocks = {
      "nix-builder" = {
        user = "root";
        hostname = "127.0.0.1";
        port = 3022;
      };
    };
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

      # jump
      eval "$(jump shell)"

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
