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
      siji
      dejavu_fonts
      hack-font
      inconsolata
      source-code-pro
      terminus_font
      ttf-envy-code-r
      ttf_bitstream_vera
    ];
  };

}
