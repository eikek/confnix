{ config, pkgs, ... }:
{
  services.libinput.enable = true;
  services.xserver = {
    enable = true;
    autorun = true;
    xkb.layout = "de";
    exportConfiguration = true;
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
        greeters = {
          gtk = {
            cursorTheme.size = 32;
          };
        };
      };
      startx = {
        enable = true;
      };
      session = [
        {
          manage = "desktop";
          name = "herbstluft";
          start = ''
            if test -e "$HOME/.Xresources"; then
              ${pkgs.xorg.xrdb}/bin/xrdb -merge $HOME/.Xresources
            fi
            ${pkgs.herbstluftwm}/bin/herbstluftwm --locked &
            waitPID=$!
          '';
        }
      ];
      defaultSession = "herbstluft";
    };
  };

  environment.systemPackages = [
    pkgs.xorg.xcursorthemes
  ];

  services.displayManager = {
    defaultSession = "herbstluft";
  };

  services.picom = {
    enable = true;
    activeOpacity = 1.0;
    inactiveOpacity = 0.9;
    shadow = false;
    # get window class via:
    #   xprop WM_CLASS
    opacityRules = [
      "100:fullscreen"
      "100:class_g = 'dmenu'"
      "100:name *= 'i3lock'"
      "100:name *= 'Teams'"
      "100:class_g = 'Toolkit'"
      "100:name *= 'Picture-in-Picture'"
      "95:class_g = 'Alacritty' && focused"
    ];
  };
}
