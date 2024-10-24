{ config, pkgs, ... }:

{
  boot.isContainer = true;
  networking.firewall.allowedTCPPorts = [ config.services.postgresql.settings.port ];

  services.postgresql =
    let
      pginit = pkgs.writeText "pginit.sql" ''
        CREATE USER dev WITH PASSWORD 'dev' LOGIN CREATEDB;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dev;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dev;
      '';
    in
    {
      enable = true;
      package = pkgs.postgresql;
      enableTCPIP = true;
      initialScript = pginit;
      settings.port = 5432;
    };
}
