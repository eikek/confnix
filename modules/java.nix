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
      #JAVA8_HOME = "${p.pkgs1903.openjdk8}/lib/openjdk";
      JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
      JDK_HOME = "${pkgs.jdk}/lib/openjdk";
      JDK11_HOME = "${pkgs.jdk11}/lib/openjdk";
      JDK21_HOME = "${pkgs.jdk21}/lib/openjdk";
      #JDK_UNSTABLE_HOME = "${p.pkgsUnstable.openjdk}/lib/openjdk";
    };
  };

}
