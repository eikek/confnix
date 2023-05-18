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
      pkgs.openjdk
    ];

    variables = {
      #JAVA8_HOME = "${p.pkgs1903.openjdk8}/lib/openjdk";
      JAVA_HOME = "${pkgs.openjdk}/lib/openjdk";
      JDK_HOME = "${pkgs.openjdk}/lib/openjdk";
      JDK11_HOME = "${pkgs.openjdk11}/lib/openjdk";
      JDK17_HOME = "${pkgs.openjdk17}/lib/openjdk";
      #JDK_UNSTABLE_HOME = "${p.pkgsUnstable.openjdk}/lib/openjdk";
    };
  };

}
