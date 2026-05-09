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
  services.displayManager.defaultSession = lib.mkForce "xfce";

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  environment.systemPackages = with pkgs; [
        firefox

        arduino-core
        arduino-cli
        arduino-mk
        arduino-ide
        fritzing
        dfu-util
        micropython
        thonny
        (python3.withPackages (p: [
          p.jedi
          p.pyserial
          p.tkinter
          p.docutils
          p.pylint
          p.mypy
          p.pyperclip
          p.asttokens
          p.send2trash
        ]))
        dfu-util
        dfu-programmer
      ];

}
