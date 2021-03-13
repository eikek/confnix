{ config, pkgs, ... }:
let
  p = import ../nixversions.nix config;
in
{
  environment = {
    systemPackages = [
      pkgs.openjdk11
    ];

    variables = {
      JAVA8_HOME = "${p.pkgs1903.openjdk8}/lib/openjdk";
      JAVA_HOME = "${pkgs.openjdk11}/lib/openjdk";
      JDK_HOME = "${pkgs.openjdk11}/lib/openjdk";
      JDK11_HOME = "${pkgs.openjdk11}/lib/openjdk";
    };
  };

}
