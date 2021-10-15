#!/bin/bash

nix-shell --run "home-manager build -f ${1:-./home.nix}"
