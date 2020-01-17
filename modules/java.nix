{ config, pkgs, ... }:
let
  p = import ../nixversions.nix config;
in
{
  environment = {
    systemPackages = [
      p.pkgs1903.openjdk8
    ];

    variables = {
      JAVA_HOME = "${p.pkgs1903.openjdk8}/lib/openjdk";
      JDK_HOME = "${p.pkgs1903.openjdk8}/lib/openjdk";
      JDK11_HOME = "${pkgs.openjdk11}/lib/openjdk";
    };
  };

}
