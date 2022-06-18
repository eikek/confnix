{ config, pkgs, ... }:

{
  services.blueman.enable = true;

  environment.systemPackages = [
    pkgs.pavucontrol
  ];

  hardware = {
    bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ ];
    };
  };

}
