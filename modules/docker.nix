users: {pkgs, config, ...}:
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  users.groups.docker = {
    members = users;
  };

  environment.systemPackages = [
    (pkgs.docker.override(args: { buildxSupport = true; }))
    pkgs.docker-compose
  ];
}
