#!/bin/bash

nix-shell --run "home-manager switch -f ${1:-./home.nix} -b old"
