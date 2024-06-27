{ config, pkgs, ... }:
let
  p = import ../nixversions.nix config;
in
{
  services.bloop = {
    install = true;
  };

  programs.java.package = pkgs.openjdk;

  environment = {
    systemPackages = [
      pkgs.jdk
    ];

    variables = {
      JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
      JDK_HOME = "${pkgs.jdk}/lib/openjdk";
      JDK17_HOME = "${pkgs.jdk17}/lib/openjdk";
      JDK11_HOME = "${pkgs.jdk11}/lib/openjdk";
      JDK21_HOME = "${pkgs.jdk21}/lib/openjdk";
    };
  };
}
