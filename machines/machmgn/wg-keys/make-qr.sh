#!/usr/bin/env nix-shell
#! nix-shell -p qrencode -i bash

qrencode -t ansiutf8 -r "$1"
