{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
      ./testconf.nix
    ];

  settings = {
  # mac 0800272ACD77
    primaryIp = "192.168.1.74";
  };

  users.extraUsers = {
    demo = {
      isNormalUser = true;
      description = "Demo user account";
      extraGroups = [ "wheel" "audio" "messagebus" "systemd-journal" ];
      password = "demo";
      uid = 1004;
    };
  };
}
