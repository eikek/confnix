{ config, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
    };
    fontDir = {
      enable = true;
    };
    enableDefaultPackages = true;

    packages = with pkgs; [
      #corefonts #unfree
      anonymousPro
      dejavu_fonts
      fantasque-sans-mono
      hack-font
      inconsolata
      iosevka
      iosevka-bin
      source-code-pro
      terminus_font
      ttf_bitstream_vera
      roboto-mono
      siji
      quivira
      nerdfonts
    ];
  };

}
