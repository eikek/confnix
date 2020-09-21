#!/usr/bin/env bash
#
# See  https://www.freecodecamp.org/news/how-to-get-https-working-on-your-local-development-environment-in-5-minutes-7af615770eec/
# https://github.com/dakshshah96/local-cert-generator/

DIR=$(dirname $0)
PASSENTRY="lokaleMaschine/rootca"

OUTDIR=$DIR/certs
mkdir -p "$OUTDIR"

# generate the key
pass $PASSENTRY | openssl genrsa -des3 -out "$OUTDIR/rootCA.key" -passout stdin  2048
pass $PASSENTRY | openssl req -x509 -new -nodes -key "$OUTDIR/rootCA.key" -passin stdin -sha256 -days 1024 -out "$OUTDIR/rootCA.pem" -subj "/C=DE/ST=Random/L=Random/O=Random/OU=Random/CN=Local Certificate"

# Add it to the nss db used by chromium and firefox
# Requires certutil (nix-shell -p nssTools)
echo "Adding root certificate to firefox and chromium trust-stores"
mkdir -p $HOME/.pki/nssdb
# chromium
certutil -d $HOME/.pki/nssdb/ -D -n 'Random' || true
certutil -d $HOME/.pki/nssdb/ -A -n 'Random' -i "$OUTDIR/rootCA.pem" -t "CT,C,C"
# firefox
certutil -d $HOME/.mozilla/firefox/*.default/ -D -n 'Random' || true
certutil -d $HOME/.mozilla/firefox/*.default/ -A -n 'Random' -i "$OUTDIR/rootCA.pem" -t "CT,C,C"
