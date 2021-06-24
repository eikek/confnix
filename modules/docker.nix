{pkgs, config, ...}:
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  users.groups.docker = {
    members = [ "eike" ];
  };

  environment.systemPackages = [
    (pkgs.docker.override(args: { buildxSupport = true; }))
    pkgs.docker-compose
  ];
}
