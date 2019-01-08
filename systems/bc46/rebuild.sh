#!/usr/bin/env bash
set -e

if [[ -z "$SUDO_USER" ]]; then
    echo "Must run via sudo."
    exit 1
fi

su $SUDO_USER -c "pass show bluecare/login | head -n1" > ~root/.password
nixos-rebuild -I serverpass=~root/.password \
              -I hinpass=~root/.hinpass \
              -I nixos1703=https://github.com/NixOS/nixpkgs/archive/17.03.tar.gz \
              -I nixos1709=https://github.com/NixOS/nixpkgs/archive/17.09.tar.gz \
              -I nixos1803=https://github.com/NixOS/nixpkgs/archive/18.03.tar.gz \
              -I nixos1809=https://github.com/NixOS/nixpkgs/archive/18.09.tar.gz "$@"
