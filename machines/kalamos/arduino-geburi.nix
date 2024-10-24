# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../modules/arduino-nano.nix
    ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  #  services.displayManager.defaultSession = "xfce";

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alice =
    let
      sshkeys = import ../../secrets/ssh-keys.nix;
    in
    {
      isNormalUser = true;
      extraGroups = [ "wheel" "disk" "camera" "keys" "dialout" ];
      openssh.authorizedKeys.keys = [ sshkeys.eike ];
      packages = with pkgs; [
        firefox

        arduino-core
        arduino-cli
        arduino-mk
        arduino-ide
        fritzing
        dfu-util
      ];
    };
}
