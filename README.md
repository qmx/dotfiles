# dotfiles

This is turning out to be mostly nix-managed nowadays

## tl;dr

Clone the repo to `~/dev/dotfiles`

[Install Nord iTerm2](https://github.com/arcticicestudio/nord-iterm2)

[Install Nix](https://nixos.org/manual/nix/stable/#sect-macos-installation)

`sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume`

## finally, run home-manager

`./switch`

## troubleshooting

if you get some weird error about insecure zsh stuff:

`compaudit | xargs chmod g-w`
