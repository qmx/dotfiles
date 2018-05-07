fpath=(
"$HOME/.zfunctions"
$fpath
)

PURE_GIT_PULL=0

bindkey -e

autoload -Uz promptinit
promptinit
prompt pure

autoload -Uz compinit
compinit

autoload bashcompinit
bashcompinit

# Show completion status
# # http://stackoverflow.com/a/844299
expand-or-complete-with-dots() {
  echo -n "\e[31m...\e[0m"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots
# Case-insensitive matching
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Use completion menu
zstyle ':completion:*' menu select

HISTFILE="$HOME/.zhistory"
HISTSIZE=50000
SAVEHIST=50000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history

setopt extendedglob

alias ls="ls -lFAh --group-directories-first --color=always"

export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$GOPATH/bin:$GOROOT/bin:/opt/neovim/bin:$PATH"
export EDITOR="nvim"

if [[ -f /mnt/secrets/.zhistory ]]; then
    HISTFILE=/mnt/secrets/.zhistory
    export HISTFILE
fi

if [[ -d /mnt/secrets/.jump ]]; then
    JUMP_HOME=/mnt/secrets/.jump
    export JUMP_HOME
fi

eval "$(direnv hook zsh)"

eval "$(jump shell)"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
