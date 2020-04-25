{ config, pkgs, ... }:
{

  environment.systemPackages = [
    pkgs.myemacs
  ];

  services.emacs = {
    enable = false;
    package = pkgs.myemacs;
    defaultEditor = true;
    install = true;
  };
}
