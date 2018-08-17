{ fetchurl, lib, makemkv }:

# test key is T-aOOAOSdZWjJvlEAkqTMx@FmIUDQ9Uw5gNT2t0HYlnR3M7MpMj4EcvPPV3rImuagWuo
#             T-NFjyvOeJ_y4pyiTEUKgI5bQMpms@HwygOuilHIWNV6_l3Z3su9psCLBHraoFktxO4O
#             T-97pzDZ1bt6gLQbt9KpzffjEI0pRF_MjHnzDHBI@nwQIQpFmCmzpTlyzHfbI1ghXsR7
#             T-Rj9dmR37zXFQlCz2ljQzy8tKHPasVYXIyREZwfDSi8uwRQjo1xw7Kzdr2iDGL@4QoW
# from: http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053
#
# if optical drive is not recognized try `modprobe sg` before starting makemkv

let
  version = "1.12.3";
in
lib.overrideDerivation makemkv (attrs: {
  name = "makemkv-${version}";

  ver = version;

  src_bin = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz";
    sha256 = "0rggpzp7gp4y6gxnhl4saxpdwnaivwkildpwbjjh7zvmgka3749a";
  };

  src_oss = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz";
    sha256 = "1w0l2rq9gyzli5ilw82v27d8v7fmchc1wdzcq06q1bsm9wmnbx1r";
  };
})
