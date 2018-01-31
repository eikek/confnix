#!/usr/bin/env bash

nixos-rebuild -I serverpass=~root/.password \
              -I hinpass=~root/.hinpass \
              -I oldpkgs=https://github.com/NixOS/nixpkgs/archive/17.03.tar.gz \
              -I nixos1709=https://github.com/NixOS/nixpkgs/archive/17.09.tar.gz "$@"
