{ offlineimap, fetchurl, lib }:
let
  version = "6.5.7";
in
lib.overrideDerivation offlineimap (attrs: rec {
  name = "offlineimap-${version}";
  src = fetchurl {
    url = "https://github.com/OfflineIMAP/offlineimap/archive/v${version}.tar.gz";
    sha256 = "18whwc4f8nk8gi3mjw9153c9cvwd3i9i7njmpdbhcplrv33m5pmp";
  };
})
