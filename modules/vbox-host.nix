{pkgs, config, ...}:
{
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "eike" ];

}
