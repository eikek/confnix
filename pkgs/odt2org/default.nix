{ stdenv, fetchurl, pythonPackages, dos2unix }:

let
 olefileio = pythonPackages.buildPythonPackage rec {
   name = "olefileio";
   version = "0.42.1";
   src = fetchurl {
     url = "https://bitbucket.org/decalage/olefileio_pl/downloads/olefile-${version}.zip";
     sha256 = "1q1n1q4hjwc7ny90khx82hgj094ki06azrkd5hdbaj8kl7djccla";
   };
   propagatedBuildInputs = with pythonPackages; [ lxml  ];
 };
in
pythonPackages.buildPythonPackage rec {
  name = "odt2org-${version}";
  version = "398f021";

  src = fetchurl {
    url = "https://bitbucket.org/josemaria.alkala/odt2org/get/tip.tar.gz";
    sha256 = "002ij1qdbqp2ssa5pr9cskb2r8jxklmvizpbg0yqspd865dggdzc";
  };

  patchPhase = ''
    ${dos2unix}/bin/dos2unix *.py
  '';
  propagatedBuildInputs = with pythonPackages; [ lxml  olefileio ];
}
