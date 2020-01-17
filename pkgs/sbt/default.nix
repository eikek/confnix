{ sbt, stdenv, fetchurl, openjdk11 }:
let
  p = import ../../nixversions.nix {};
in {
  sbt = sbt.override { stdenv = stdenv; fetchurl = fetchurl; jre = p.pkgs1903.jre8; };

  sbt11 = sbt.override { stdenv = stdenv; fetchurl = fetchurl; jre = openjdk11; };
}
