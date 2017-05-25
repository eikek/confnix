{ stdenv, callPackage, nodejs, fetchzip, gmp }:

let
  nodePackages = callPackage (import <nixpkgs/pkgs/top-level/node-packages.nix>) {
    inherit nodejs;
    self = nodePackages;
    generated = ./deps.nix;
  };
in
nodePackages.buildNodePackage rec {
  version = "4.0.0-e4cfa44";
  name = "elm-test-${version}";

  src = fetchzip {
    url = https://github.com/rtfeldman/node-test-runner/archive/e4fca440b9156cd8224ae0c2ac873ff5b0b64df8.zip;
    name = "elm-test-e4fca44.zip";
    sha256 = "1gymvhipfqbr1va4nwgghzyz8q7ji0k8l8mj0zpzzvhkl64icw88";
  };

  deps = with stdenv.lib; (filter (v: nixType v == "derivation") (attrValues nodePackages));

  postInstall = ''
    interpreter=$(echo ${stdenv.glibc.out}/lib/ld-linux*.so.2)
    patchelf --set-interpreter $interpreter $out/lib/node_modules/elm-test/bin/elm-interface-to-json
    patchelf --set-rpath ${gmp}/lib $out/lib/node_modules/elm-test/bin/elm-interface-to-json
  '';
}
