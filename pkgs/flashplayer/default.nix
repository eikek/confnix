{ stdenv, fetchurl, lib, flashplayer }:

lib.overrideDerivation flashplayer (attrs: rec {
  version = "11.2.202.466";
  name = "flashplayer-${version}";
  src =  if (stdenv.system == "x86_64-linux") then
    fetchurl {
      url = "http://fpdownload.adobe.com/get/flashplayer/pdc/${version}/install_flash_player_11_linux.x86_64.tar.gz";
      sha256 = "1clwfhq57gck638sj7i19gxar1z5ks2zfdw1p9iln515a57ik158";
    }
    else if (stdenv.system == "i686-linux") then fetchurl {
      url = "http://fpdownload.adobe.com/get/flashplayer/pdc/11.2.202.466/install_flash_player_11_linux.i386.tar.gz";
      sha256 = "1vzxai3b6d7xs34h7qj1nal9i7vvnv6k7rb37rqxaiv2yf58nw9h";
    }
    else throw "Flashplayer not supported on your platform.";
})
