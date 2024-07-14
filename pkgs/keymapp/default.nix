{ stdenvNoCC
, buildFHSEnv
, fetchurl
, libusb1
, libudev-zero
, webkitgtk
, gtk3
, gdk-pixbuf
, glib
, libstdcxx5
, libgcc
}:
let
  keymappbin = stdenvNoCC.mkDerivation {
    name = "keymapbin";
    src = fetchurl {
      url =
        "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz";
      sha256 = "sha256-e02EOJH7QXm8ue7pZt++tyUjAC+DFga4MWNoeVfJjy8=";
    };
    unpackPhase = ''
      tar xf $src
    '';
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp keymapp $out/bin
      chmod 755 $out/bin/keymapp
    '';
  };
in
buildFHSEnv {
  name = "keymapp";
  runScript = "${keymappbin}/bin/keymapp";
  targetPkgs = p:
    with p; [
      libusb1
      libudev-zero
      webkitgtk
      gtk3
      gdk-pixbuf
      glib
    ];
}
