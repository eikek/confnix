{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "10.11.1.1";
  name = "apache-derby-${version}";

  src = fetchurl {
    url = "http://www.pirbot.com/mirrors/apache/db/derby/db-derby-${version}/db-derby-${version}-bin.zip";
    md5 = "aec1b230e6ca4a5bbce0003b5d88e55f";
  };

  buildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/{derby,bin}
    cd db-derby*
    mv * $out/derby/
    ln -snf $out/derby/bin/ij $out/bin/derby-ij
    ln -snf $out/derby/bin/dblook $out/bin/derby-dblook
    ln -snf $out/derby/bin/sysinfo $out/bin/derby-sysinfo
  '';

  meta = with stdenv.lib; {
    description = "Apache Derby is an open source relational database implemented entirely in Java.";
    homepage = https://db.apache.org/derby/index.html;
    license = licenses.asl20;
    maintainers = [ maintainers.eikek ];
  };
}
