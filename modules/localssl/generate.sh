#!/usr/bin/env nix-shell
#! nix-shell -p nssTools -i bash

echo "Generating root certificate and one for localhost…"

./generate-root.sh
./generate-localhost.sh

echo "Rebuild NixOS now."
