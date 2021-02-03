#!/bin/sh

mkdir -p ~/.config/nix && echo "sandbox = false" > ~/.config/nix/nix.conf"
curl -L https://nixos.org/nix/install | sh

./switch.sh
