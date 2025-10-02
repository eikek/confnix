#!/usr/bin/env nix-shell
#! nix-shell -p wireguard-tools -i bash

name="$1"
if [ -z "$name" ]; then
    echo "No name given."
    exit 1
fi

wg genkey | tee "$name.private" | wg pubkey > "$name.public"
