{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ # Include the results of the hardware scan.
      ./configuration.nix
    ];


  settings.primaryDomain = "testvm.com";
  settings.primaryIp = "192.168.1.59";

  networking = {
    hostName = "myserver";
    firewall = {
      allowedTCPPorts = [ 22 25 587 143 80 443 29418 ];
    };
  };

}
