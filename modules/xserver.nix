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
      lightdm = {
        enable = true;
      };
      startx = {
        enable = true;
      };
      session = [
        { manage = "desktop";
          name = "herbstluft";
          start = ''
            ${pkgs.herbstluftwm}/bin/herbstluftwm --locked &
            waitPID=$!
          '';
        }
      ];
      defaultSession = "herbstluft";
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
