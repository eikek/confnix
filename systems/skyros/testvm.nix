{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
      ./testconf.nix
    ];


  virtualisation = {
    diskSize = 9210;
    memorySize = 2048;
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
