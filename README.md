# dotfiles

This is turning out to be mostly nix-managed nowadays

## tl;dr

Clone the repo to `~/dev/dotfiles`

[Install Nord iTerm2](https://github.com/arcticicestudio/nord-iterm2)

[Install Nix](https://nixos.org/manual/nix/stable/#sect-macos-installation)

`sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume`

[Install Home Manager](https://github.com/nix-community/home-manager#installation)

```
$ nix-channel --add https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz home-manager
$ nix-channel --update
$ nix-shell '<home-manager>' -A install
```

Then finally

`HOME_MANAGER_CONFIG=~/dev/dotfiles/home-manager/home.nix home-manager switch`

## troubleshooting

if you get some weird error about insecure zsh stuff:

`compaudit | xargs chmod g-w`
