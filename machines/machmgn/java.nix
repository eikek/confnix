{ config, pkgs, ... }:

{
  programs.java.package = pkgs.openjdk;

  environment = {
    systemPackages = [
      pkgs.jdk
    ];

    variables = {
      JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
      JDK_HOME = "${pkgs.jdk}/lib/openjdk";
      JDK21_HOME = "${pkgs.jdk21}/lib/openjdk";
    };
  };
}
