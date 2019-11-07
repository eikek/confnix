{ config, pkgs, ... }:

{
  environment = {
    systemPackages = [
      pkgs.openjdk8
    ];

    variables = {
      JAVA_HOME = "${pkgs.openjdk8}/lib/openjdk";
      JDK_HOME = "${pkgs.openjdk8}/lib/openjdk";
      JDK11_HOME = "${pkgs.openjdk11}/lib/openjdk";
    };
  };

}
