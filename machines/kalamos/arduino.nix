{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../modules/arduino-nano.nix
    ];

  environment.systemPackages = with pkgs; [
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
