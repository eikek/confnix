{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ../../common-desktop.nix
      ./services.nix
      <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_4_2;
  };

  virtualbox.baseImageSize = 18 * 1024;

  users.extraUsers.eike = {
    password = "eike";
  };
  users.extraUsers.root = {
    password = "root";
  };

  networking = {
    hostName = "shangv";
    hostId = "b43f228a";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;
    firewall = {
      allowedTCPPorts = [ 8080 ];
    };
  };
}
