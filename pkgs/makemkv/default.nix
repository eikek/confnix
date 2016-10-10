{ fetchurl, lib, makemkv }:

# test key is T-Rj9dmR37zXFQlCz2ljQzy8tKHPasVYXIyREZwfDSi8uwRQjo1xw7Kzdr2iDGL@4QoW
# from: http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053

let
  version = "1.10.2";
in
lib.overrideDerivation makemkv (attrs: {
  name = "makemkv-${version}";

  ver = version;

  src_bin = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz";
    sha256 = "0dqlpf5n9lbc3lp6h8f7gzysq7h51h4ck5bjvcwrm9qkyrlaypxp";
  };

  src_oss = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz";
    sha256 = "1bb57kc3l1m9naqh12n4vzkg81svyglbwzh6i2idad7r0dv5kkpb";
  };
})
