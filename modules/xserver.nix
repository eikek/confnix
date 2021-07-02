{ config, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;
    libinput.enable = true;
#    xkbVariant = "neo";

    desktopManager = {
      xterm.enable = false;
    };
    windowManager = {
      herbstluftwm.enable = true;
    };
    displayManager = {
      defaultSession = "none+herbstluftwm";
    };
  };

  services.picom = {
    enable = true;
    activeOpacity = 1.0;
    inactiveOpacity = 0.9;
    shadow = false;
    opacityRules = [
      "100:fullscreen"
      "100:class_g = 'dmenu'"
      "100:name *= 'i3lock'"
      "100:name *= 'Teams'"
      "95:class_g = 'Alacritty' && focused"
    ];
  };
}
