fpath=(
"$HOME/.zfunctions"
$fpath
)

autoload -Uz promptinit
promptinit
prompt pure

autoload -Uz compinit
compinit

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

setopt extendedglob

export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$GOPATH/bin:$GOROOT/bin:$PATH"
export EDITOR="nvim"

if [[ -d /mnt/secrets ]]; then
    HISTFILE=/mnt/secrets/.zhistory
fi

eval "$(direnv hook zsh)"

eval "$(jump shell)"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
