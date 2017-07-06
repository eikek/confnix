{ fetchurl, lib, makemkv }:

# test key is T-Rj9dmR37zXFQlCz2ljQzy8tKHPasVYXIyREZwfDSi8uwRQjo1xw7Kzdr2iDGL@4QoW
#             T-QWvg95pFZPQjcwoog2PxbrAlj1Ml279L3GogBfgVENxFW6fMTGgrW@RPN6aPAVH31O
# from: http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053

let
  version = "1.10.6";
in
lib.overrideDerivation makemkv (attrs: {
  name = "makemkv-${version}";

  ver = version;

  src_bin = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz";
    sha256 = "1qy3zbp8qmw717ni263f3ycba4p3rccqwqz6vkia9jb60578xmlr";
  };

  src_oss = fetchurl {
    url = "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz";
    sha256 = "0dfjg3yj6z723lp77x1fvrwm6mggr6976skfnycxiwk4afh8n0mb";
  };
})
