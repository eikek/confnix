#!/usr/bin/env bash

set -e
THISDIR=$(dirname $(readlink -e $0))

if [ -z "$SUDO_USER" ]; then
    echo "Must run using sudo!"
    exit 1
fi

ACTION="$1"
shift
if [ -z "$ACTION" ]; then
    echo "No nixos-rebuild action given"
    exit
fi

if [ -z "$1" ]; then
    echo "Password entries are required as arguments"
    exit 1
fi

SSH_PUBKEY=${SSH_PUBKEY:-/home/$SUDO_USER/.ssh/id_rsa.pub}

echo "Using this ssh public key: $SSH_PUBKEY"
echo "Set SSH_PUBKEY env variable to change this. Proceed?"
read

echo "Create accounts.nix ..."
su -s /bin/sh $SUDO_USER -c "$THISDIR/../scripts/pass2accounts.sh $@" > accounts.nix
chmod 600 accounts.nix

echo nixos-rebuild -I sshpubkey="$SSH_PUBKEY" -I accounts=$(pwd)/accounts.nix $ACTION
nixos-rebuild -I sshpubkey="$SSH_PUBKEY" -I accounts=$(pwd)/accounts.nix $ACTION
