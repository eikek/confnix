#!/usr/bin/env bash

set -e
THISDIR=$(dirname $(readlink -e $0))

if [ -z "$SUDO_USER" ]; then
    echo "Must run using sudo!"
    exit 1
fi

ACTION="$1"
shift || {
    echo "No nixos-rebuild action given"
    exit 1
}

if [ -z "$1" ]; then
    echo "Password entries are required as arguments"
    exit 1
fi

SSH_PUBKEY=${SSH_PUBKEY:-/home/$SUDO_USER/.ssh/id_rsa.pub}
if [ ! -e "$SSH_PUBKEY" ]; then
    echo "No ssh public key found. Default in $SSH_PUBKEY doesn't exist"
    echo "Set SSH_PUBKEY env variable."
    exit 1
fi
echo "Using this ssh public key:"
echo
echo "    $SSH_PUBKEY"
echo
echo "Set SSH_PUBKEY env variable to change this."
echo "Proceed?"
read

echo "Create accounts.nix ..."
su -s /bin/sh $SUDO_USER -c "$THISDIR/pass2accounts.sh $*" > accounts.nix
chmod 600 accounts.nix

echo nixos-rebuild -I sshpubkey="$SSH_PUBKEY" -I accounts=$(pwd)/accounts.nix "$ACTION"
nixos-rebuild -I sshpubkey="$SSH_PUBKEY" -I accounts=$(pwd)/accounts.nix "$ACTION"
