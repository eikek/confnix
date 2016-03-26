{ fetchurl, lib, makemkv }:
let
  version = "1.9.9";
in
lib.overrideDerivation makemkv (attrs: {
  name = "makemkv-${version}";

  ver = version;

  src_bin = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz";
    sha256 = "1rsmsfyxjh18bdj93gy7whm4j6k1098zfak8napxsqfli7dyijb6";
  };

  src_oss = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz";
    sha256 = "070x8l88nv70abd9gy8jchs09mh09x6psjc0zs4vplk61cbqk3b0";
  };
})
