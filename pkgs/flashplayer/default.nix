{ stdenv, fetchurl, lib, flashplayer }:
# https://fpdownload.adobe.com/get/flashplayer/pdc/11.2.202.559/install_flash_player_11_linux.x86_64.tar.gz
lib.overrideDerivation flashplayer (attrs: rec {
  version = "11.2.202.559";
  name = "flashplayer-${version}";
  src =  if (stdenv.system == "x86_64-linux") then
    fetchurl {
      url = "http://fpdownload.adobe.com/get/flashplayer/pdc/${version}/install_flash_player_11_linux.x86_64.tar.gz";
      sha256 = "1dh80g222r3qr5xz16akhp64knndng0jsphnlq8ih69fm81ixfpb";
    }
    else if (stdenv.system == "i686-linux") then fetchurl {
      url = "http://fpdownload.adobe.com/get/flashplayer/pdc/11.2.202.466/install_flash_player_11_linux.i386.tar.gz";
      sha256 = "1vzxai3b6d7xs34h7qj1nal9i7vvnv6k7rb37rqxaiv2yf58nw9h";
    }
    else throw "Flashplayer not supported on your platform.";
})
