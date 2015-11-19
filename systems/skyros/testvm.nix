{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
      ./testconf.nix
    ];


  virtualisation = {
    diskSize = 5210;
  };

}
