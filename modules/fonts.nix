{ config, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
    };
    enableDefaultFonts = true;
    enableFontDir = true;
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
    ];
  };

}
