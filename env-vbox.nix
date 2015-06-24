{ config, pkgs, ... }:

{

  users.extraUsers.eike.extraGroups = [ "vboxusers" ];

  services.virtualboxHost.enable = true;
  services.virtualboxHost.enableHardening = true;

}
