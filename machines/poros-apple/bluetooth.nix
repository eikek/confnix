{ config, lib, pkgs, ... }:

{
  services.blueman.enable = true;

  environment.systemPackages = [
    pkgs.pavucontrol
    pkgs.pwvucontrol
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  hardware = {
    bluetooth = {
      enable = false;
    };

    pulseaudio = {
      enable = false;
    };
  };
}
