{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "mc3ppd";

  src = fetchurl {
    url = "https://printing.sp.ethz.ch/ethps/SiteAssets/Linux/02-MC3_MPC3003.ppd";
    name = "02-MC3_MPC3003.ppd";
    sha256 = "sha256-QCcPJ5Nv62LIlzmRPdjudwBix+ZMJCJmlcISHKhSin4=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/cups/model/ricoh
    cp $src $out/share/cups/model/ricoh/mp_c3003ps.ppd
  '';
}
