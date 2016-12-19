{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  name = "utax-ccd-clp-ppd";

  src = fetchurl {
    url = http://www.utax.com/C125712200447418/vwLookupDownloads/TALinuxPackages_cCD-cLP_20140115.tar.gz/$FILE/TALinuxPackages_cCD-cLP_20140115.tar.gz;
    sha256 = "1bbjw62y2j2ya0xdh9d9pnmfi4rc16dv3yf910pr2ri2nf1140ym";
  };

  installPhase = ''
    mkdir -p $out/share/cups/model/utax
    ## this file contains many many ppd files, but I only need one
    cp 3005ci\ series/64bit/EU/German/TA3505ci.PPD $out/share/cups/model/utax/ta3505ci.ppd
  '';
}
