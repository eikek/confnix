 { config, pkgs, ... }:

{ services.postgresql =
  let
    pginit = pkgs.writeText "pginit.sql" ''
      CREATE USER dev WITH PASSWORD 'dev' LOGIN CREATEDB;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dev;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dev;
    '';
  in {
    enable = true;
    package = pkgs.postgresql;
    enableTCPIP = true;
    initialScript = pginit;
    port = 5432;
  };
}
