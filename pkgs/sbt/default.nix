{ sbt, stdenv, fetchurl, openjdk11, openjdk8 }:
{
  sbt8 = sbt.override { stdenv = stdenv; fetchurl = fetchurl; jre = openjdk8; };
  sbt11 = sbt.override { stdenv = stdenv; fetchurl = fetchurl; jre = openjdk11; };
}
