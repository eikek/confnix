{ config, pkgs, ... }:
{
  services.libinput.enable = true;
  services.xserver = {
    enable = true;
    autorun = true;
    xkb.layout = "de";
    exportConfiguration = true;

    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager = {
    sddm = {
      enable = true;
    };
    defaultSession = "xfce";
  };

  programs.xwayland = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    xfce.catfish
    xfce.gigolo
    xfce.orage
    xfce.ristretto
    xfce.xfburn
    xfce.xfce4-appfinder
    xfce.xfce4-battery-plugin
    xfce.xfce4-clipman-plugin
    xfce.xfce4-cpugraph-plugin
    xfce.xfce4-dict
    xfce.xfce4-fsguard-plugin
    xfce.xfce4-genmon-plugin
    xfce.xfce4-icon-theme
    xfce.xfce4-netload-plugin
    xfce.xfce4-panel
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-settings
    xfce.xfce4-systemload-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-whiskermenu-plugin
    xfce.xfce4-xkb-plugin
    xfce.xfdashboard
    xcursor-themes
    xev
    elementary-xfce-icon-theme
    amber-theme
    font-manager
  ];

  services.blueman.enable = true;

  programs = {
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };
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
