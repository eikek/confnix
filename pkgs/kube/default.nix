{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "5.0";
  name = "kube-${version}";

  src = fetchurl {
    url = https://imperavi.com/download/kube/updates/;
    name = "kube-${version}-download.zip";
    sha256 = "144vic75zvvb4g958lywgm83fh39nrcjj12bn6xjh7vr3c4909px";
  };

  buildInputs = [ unzip ];

  unpackPhase = ''
    unzip ${src} kube500/*
  '';
  /**/

  installPhase = ''
    mkdir -p $out/
    cp -r css $out/
    cp index.html $out/
  '';

  meta = with stdenv.lib; {
    description = "Kube CSS Web Framework";
    homepage = http://imeravi.com/kube/;
    license = licenses.mit;
    maintainers = [ maintainers.eikek ];
  };
}
