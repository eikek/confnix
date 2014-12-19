{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "4.02";
  name = "kube-${version}";

  src = fetchurl {
    url = http://imperavi.com/webdownload/kube/get/;
    name = "kube-${version}-download.zip";
    sha256 = "06wpcyhkbca4lddcydyslvr8583pk8n5ca6nbdp72ngklbq5gfgd";
  };

  buildInputs = [ unzip ];

  unpackPhase = ''
    unzip ${src} kube402/*
    cd kube402
  '';
  /**/

  installPhase = ''
    mkdir -p $out/
    cp -r css $out/
    cp -r js $out/
    cp index.html $out/
  '';

  meta = with stdenv.lib; {
    description = "Kube CSS Web Framework";
    homepage = http://imeravi.com/kube/;
    license = licenses.mit;
    maintainers = [ maintainers.eikek ];
  };
}
