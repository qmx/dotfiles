#!/bin/sh

NIX_VERSION=2.3.10
NIX_SHASUM=8fa6f064bf758adf501deb35c6837b8c4f9402f66ff86964537524103376958e

mkdir -p ~/.config/nix && echo "sandbox = false" > ~/.config/nix/nix.conf
curl -o /tmp/nix.sh "https://releases.nixos.org/nix/nix-${NIX_VERSION}/install" \
  && echo "${NIX_SHASUM}  /tmp/nix.sh" | shasum -c - \
  && /bin/sh -e "/tmp/nix.sh" \
  && rm /tmp/nix.sh
. ~/.nix-profile/etc/profile.d/nix.sh
