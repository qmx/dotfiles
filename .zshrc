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

export PATH="$(brew --prefix)/opt/ruby/bin:$(brew --prefix)/lib/ruby/gems/3.0.0/bin:$PATH"

if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
       gpg-connect-agent /bye >/dev/null 2>&1
fi

gpg-connect-agent updatestartuptty /bye >/dev/null

export GPG_TTY=$(tty)

if [[ -z "$SSH_AUTH_SOCK" ]] || [[ "$SSH_AUTH_SOCK" == *"apple.launchd"* ]]; then
       SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
       export SSH_AUTH_SOCK
fi

eval "$(direnv hook zsh)"
eval "$(starship init zsh)"