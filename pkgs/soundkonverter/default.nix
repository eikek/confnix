{ stdenv, fetchurl, cmake, taglib_1_9, gettext, cdparanoiax, kde4, automoc4}:

stdenv.mkDerivation rec {
  name = "soundkonverter";
  version = "2.1.2";
  src = fetchurl {
    url = https://github.com/HessiJames/soundkonverter/archive/v2.1.2.tar.gz;
    sha256 = "1xp093q1356f26n67b64jyhwiszl6w5b0f0mav4038hw4mqk8jx5";
  };

  prePatch = "cd src";

  enableParallelBuilding = true;

  buildInputs = [ cmake taglib_1_9 gettext automoc4
    kde4.kdelibs kde4.libkcddb kde4.audiocd_kio
    cdparanoiax ];

  propagatedUserEnvPkgs = [ kde4.oxygen_icons ];

  meta = with stdenv.lib; {
    description = "A frontend to various audio converters";
    homepage = https://github.com/HessiJames/soundkonverter;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.eikek ];
  };
}
