{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  version = "2.1.3";
  name = "jquery-${version}";

  srcMin = fetchurl {
    url = "http://code.jquery.com/jquery-${version}.min.js";
    sha256 = "1hxxcff7v7201sbiyxjx3yny7insky0n5s2hr3ndkkz1fpb3pyca";
  };
  srcDev = fetchurl {
    url = "http://code.jquery.com/jquery-${version}.js";
    sha256 = "0kzr4r9150hq2ksi0422y8wb6pkrz0197zi7bmdrq3s3rg5bp342";
  };

  srcs = [ srcMin srcDev ];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/js
    cp $srcMin $out/js/jquery.min.js
    cp $srcDev $out/js/jquery.js
  '';

  meta = with stdenv.lib; {
    description = "JQuery 2.x";
    homepage = http://jquery.com;
    license = licenses.mit;
    maintainers = [ maintainers.eikek ];
  };
}
