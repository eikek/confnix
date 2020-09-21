#!/usr/bin/env bash

DIR=$(dirname $0)
PASSENTRY="lokaleMaschine/rootca"

OUTDIR=$DIR/certs
sudo mkdir -p "$OUTDIR"

csrcnf=$(mktemp -p "$DIR" "server.XXXXX.cnf")
v3cnf=$(mktemp -p "$DIR" "v3.XXXXX.ext")
cat > $csrcnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=US
ST=RandomState
L=RandomCity
O=RandomOrganization
OU=RandomOrganizationUnit
emailAddress=hello@example.com
CN = localhost
EOF

cat > $v3cnf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
EOF


pass $PASSENTRY | openssl req -passout stdin -new -sha256 -nodes -out "$OUTDIR/server.csr" -newkey rsa:2048 -keyout "$OUTDIR/server.key" -config <( cat "$csrcnf" )

pass $PASSENTRY | openssl x509 -req -in "$OUTDIR/server.csr" -CA "$OUTDIR/rootCA.pem" -passin stdin -CAkey "$OUTDIR/rootCA.key" -CAcreateserial -out "$OUTDIR/server.crt" -days 500 -sha256 -extfile "$v3cnf"

rm "$csrcnf" "$v3cnf"
