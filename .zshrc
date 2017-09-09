source /usr/share/zgen/zgen.zsh
  
if ! zgen saved; then
    zgen prezto prompt theme 'sorin'
    zgen prezto
    zgen prezto git
    zgen prezto ssh
    zgen prezto syntax-highlighting
    zgen save
fi

export GOROOT="$HOME/.go/go"
export GOPATH="$HOME/go"
export PATH="$HOME/bin:$HOME/.cargo/bin:$GOPATH/bin:$GOROOT/bin:$PATH"

eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
