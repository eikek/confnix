{stdenv, fetchurl, expat, erlang, zlib, openssl, pam, lib
 , automake, autoconf, git, cacert, libyaml }:

stdenv.mkDerivation rec {
  version = "15.11";
  name = "ejabberd-${version}";
  src = fetchurl {
    url = "http://www.process-one.net/downloads/ejabberd/${version}/${name}.tgz";
    sha256 = "0sll1si9pd4v7yibzr8hp18hfrbxsa5nj9h7qsldvy7r4md4n101";
  };

  buildInputs = [ expat erlang zlib openssl libyaml pam autoconf automake git ];

  patchPhase = ''
    sed -i \
      -e "s|erl \\\|${erlang}/bin/erl \\\|" \
      -e 's|EXEC_CMD=\"sh -c\"|EXEC_CMD=\"${stdenv.shell} -c\"|' \
      ejabberdctl.template
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = ["--enable-pam"];

  SSL_CERT_FILE = cacert + "/etc/ca-bundle.crt";

  meta = {
    description = "Open-source XMPP application server written in Erlang";
    license = stdenv.lib.licenses.gpl2;
    homepage = http://www.ejabberd.im;
    maintainers = [ lib.maintainers.eikek ];
  };
}
