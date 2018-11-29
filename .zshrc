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


export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$GOPATH/bin:$GOROOT/bin:$PATH"
export EDITOR="vim"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

case `uname` in
	Darwin)
		alias ls="ls -lFAh"
		if [[ -z "$SSH_AUTH_SOCK" ]] || [[ "$SSH_AUTH_SOCK" == *"apple.launchd"* ]]; then
			SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
			export SSH_AUTH_SOCK
		fi
		;;
	Linux)
		alias ls="ls -lFAh --group-directories-first --color=always"
		;;
esac

# inside a container, assumes it's running inside a qmxme/wk docker container
if [[ -f "/.dockerenv" ]]; then
	if 	[[ ! -s /var/run/docker.sock ]]; then
		DOCKER_HOST="tcp://docker:2375"
		export DOCKER_HOST
	fi

	if [[ -f "/mnt/secrets/$USER/.zhistory" ]]; then
		HISTFILE="/mnt/secrets/$USER/.zhistory"
		export HISTFILE
	fi

	if [[ -d "/mnt/secrets/$USER/pack" ]]; then
		stow -v -d "/mnt/secrets/$USER" -t "$HOME" pack
	fi
fi

eval "$(direnv hook zsh)"
eval "$(jump shell)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
