{ stdenv, fetchurl, freetype, fontconfig, xorg, zlib, jdk, glib, gtk, webkitgtk2, makeWrapper, unzip }:

stdenv.mkDerivation rec {
  version = "3.0.0";

  name = "elexis-${version}";

  src = fetchurl {
    url = "http://download.elexis.info/elexis.3.core/${version}/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip";
    sha256 = "05yq1zz7r447m00j229bd21dwlbi8gabdr46yp668hs70w5ajlwc";
  };

  buildInputs = [ makeWrapper unzip ];

  unpackPhase = "true";

  buildCommand = ''
    mkdir -p $out
    # Unpack tarball.
    unzip $src -d $out

    # Patch binaries.
    interpreter=$(echo ${stdenv.glibc.out}/lib/ld-linux*.so.2)
    libCairo=$out/libcairo-swt.so
    patchelf --set-interpreter $interpreter $out/Elexis3
    [ -f $libCairo ] && patchelf --set-rpath ${freetype}/lib:${fontconfig}/lib:${xorg.libX11}/lib:${xorg.libXrender}/lib:${zlib}/lib $libCairo

    # Create wrapper script.  Pass -configuration to store
    # settings in ~/.eclipse/org.eclipse.platform_<version> rather
    # than ~/.eclipse/org.eclipse.platform_<version>_<number>.

    makeWrapper $out/Elexis3 $out/bin/Elexis3 \
      --prefix PATH : ${jdk}/bin \
      --prefix LD_LIBRARY_PATH : ${glib}/lib:${gtk.out}/lib:${xorg.libXtst}/lib${stdenv.lib.optionalString (webkitgtk2 != null) ":${webkitgtk2}/lib"}
  '';

  meta = {
    homepage = http://elexis.info;
    description = ''Elexis is an Eclipse RCP program for all aspects
      of a medical practice: electronic medical record (EMR),
      laboratory findings etc., as well as accounting, billing (swiss
      TARMED-System, other systems to be developped) and other daily
      work.'';
    license = stdenv.lib.licenses.epl10;
  };

}
