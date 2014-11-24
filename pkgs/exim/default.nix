{stdenv, fetchurl, pcre, db, gnutls, libiconv, pkgconfig, sqlite, perl, which, exim_user ? "exim" }:

stdenv.mkDerivation rec {
  version = "4.84";
  name = "exim-${version}";

  # buildinfo plugin reads the current commit on build
  # thus, need to build from git sources
  src = fetchurl {
    url = "ftp://ftp.univie.ac.at/applications/exim/exim/exim4/exim-${version}.tar.bz2";
    sha256 = "174yifry1ji6i87xbvcx1k5cxxlyxhxjyj7xwy0ghvgvhyz25skq";
  };

  buildInputs = [ pcre db libiconv gnutls pkgconfig sqlite perl which ];

  configurePhase = ''
    cat >> Local/Makefile << EOF
    USE_DB=yes
    DBMLIB = -ldb
    CONFIGURE_FILE=$out/etc/exim.conf
    TRUSTED_CONFIG_LIST=$out/etc/trusted-configs
    BIN_DIRECTORY=/var/setuid-wrappers
    SPOOL_DIRECTORY=/var/exim-${version}/spool
    INFO_DIRECTORY=$out/share/info
    LOG_FILE_PATH=syslog
    SYSLOG_LOG_PID=yes
    SYSTEM_ALIASES_FILE=$out/etc/aliases
    EXIM_USER=ref:${exim_user}
    WITH_CONTENT_SCAN=yes
    HAVE_ICONV=yes
    CFLAGS=-O -I${libiconv}/include

    SUPPORT_TLS=yes
    USE_GNUTLS=yes
    USE_GNUTLS_PC=gnutls
    AVOID_GNUTLS_PKCS11=yes

    HAVE_IPV6=YES
    PCRE_CONFIG=yes
    RM_COMMAND=$(which rm)
    MV_COMMAND=$(which mv)
    CHOWN_COMMAND=$(which chown)
    COMPRESS_COMMAND=$(which gzip)
    ZCAT_COMMAND=$(which zcat)
    CHGRP_COMMAND=$(which chgrp)
    CHMOD_COMMAND=$(which chmod)
    TOUCH_COMMAND=$(which touch)
    PERL_COMMAND=$(which perl)

    FIXED_NEVER_USERS=root

    ROUTER_ACCEPT=yes
    ROUTER_DNSLOOKUP=yes
    ROUTER_IPLITERAL=yes
    ROUTER_MANUALROUTE=yes
    ROUTER_QUERYPROGRAM=yes
    ROUTER_REDIRECT=yes
    TRANSPORT_APPENDFILE=yes
    TRANSPORT_AUTOREPLY=yes
    TRANSPORT_PIPE=yes
    TRANSPORT_SMTP=yes
    LOOKUP_DBM=yes
    LOOKUP_LSEARCH=yes
    LOOKUP_DNSDB=yes
    LOOKUP_SQLITE=yes
    LOOKUP_SQLITE_PC=sqlite3
    SUPPORT_MAILDIR=yes
    SUPPORT_MAILSTORE=yes

    WITH_CONTENT_SCAN=yes
    AUTH_PLAINTEXT=yes
    EXTRALIBS_EXIM=-L${libiconv}/lib -liconv
    EOF
  '';

  buildPhase = "make";

  installPhase = ''
   mkdir -p $out/
   # the following two lines remove the call to exim to get the version number
   # you must be root to do that or exim, which does not exist (yet)
   sed -i 's,version=exim-.*exim -bV -C /dev/null.*,version=exim-${version},' scripts/exim_install
   sed -i 's,awk ./Exim version/ { OFS="".*,,' scripts/exim_install
   make INST_BIN_DIRECTORY=$out/bin INSTALL_ARG=-no_chown install
   cat > $out/etc/trusted-configs << EOF
   /var/exim-${version}/etc/exim.conf
   /var/exim/etc/exim.conf
   EOF
  '';

  meta = {
    description = "Exim is a message transfer agent (MTA) developed at the University of Cambridge for use on Unix systems connected to the Internet.";
    homepage = http://exim.org/index.html;
    license = stdenv.lib.licenses.gpl3;
    maintainers = [ stdenv.lib.maintainers.eikek ];
  };
}
