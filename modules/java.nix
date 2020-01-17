{ config, pkgs, ... }:
let
  nixpkgs1903 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-19.03.tar.gz";
    sha256 = "1b3h4mwpi10blzpvgsc0191k4shaw3nw0qd2p82hygbr8vv4g9dv";
  };
  pkgs1903 = import nixpkgs1903 { config = config; };
in
{
  environment = {
    systemPackages = [
      pkgs1903.openjdk8
    ];

    variables = {
      JAVA_HOME = "${pkgs1903.openjdk8}/lib/openjdk";
      JDK_HOME = "${pkgs1903.openjdk8}/lib/openjdk";
      JDK11_HOME = "${pkgs.openjdk11}/lib/openjdk";
    };
  };

}
