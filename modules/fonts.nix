{ config, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
    };
    fontDir = {
      enable = true;
    };
    enableDefaultFonts = true;

    fonts = with pkgs; [
      #corefonts #unfree
      anonymousPro
      dejavu_fonts
      fantasque-sans-mono
      hack-font
      inconsolata
      iosevka
      iosevka-bin
      siji
      source-code-pro
      terminus_font
      ttf-envy-code-r
      ttf_bitstream_vera
      roboto-mono
    ];
  };

}
