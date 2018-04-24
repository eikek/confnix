{ fetchurl, lib, makemkv }:

# test key is T-NFjyvOeJ_y4pyiTEUKgI5bQMpms@HwygOuilHIWNV6_l3Z3su9psCLBHraoFktxO4O
#             T-97pzDZ1bt6gLQbt9KpzffjEI0pRF_MjHnzDHBI@nwQIQpFmCmzpTlyzHfbI1ghXsR7
#             T-Rj9dmR37zXFQlCz2ljQzy8tKHPasVYXIyREZwfDSi8uwRQjo1xw7Kzdr2iDGL@4QoW
# from: http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053
#
# if optical drive is not recognized try `modprobe sg` before starting makemkv

let
  version = "1.12.0";
in
lib.overrideDerivation makemkv (attrs: {
  name = "makemkv-${version}";

  ver = version;

  src_bin = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz";
    sha256 = "167l6d3hxnms4cbkhb2yx14r6119k2w4rlm9kriwxj1mz1z1q6vd";
  };

  src_oss = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz";
    sha256 = "1cz2mmz4s1fl3xfsqw1qzx7fwhgwz13sy7hjm4kbfxpvbjsy5v8q";
  };
})
