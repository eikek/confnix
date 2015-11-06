{ pkgs ? (import <nixpkgs> {}) }:

pkgs.stdenv.mkDerivation {
  name = "systemjdk7";
  buildCommand = ''
    mkdir -p $out/lib
    ln -s ${pkgs.openjdk7}/lib/openjdk $out/lib/openjdk7
  '';
}
