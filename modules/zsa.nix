{ config, pkgs, ... }:

{
  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = [
    pkgs.wally-cli
    pkgs.keymapp
  ];
}
