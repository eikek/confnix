{ config, pkgs, ... }:

{
  services.blueman.enable = true;

  environment.systemPackages = [
    pkgs.pavucontrol
    pkgs.pwvucontrol
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

  services.pipewire.enable = false;
}
