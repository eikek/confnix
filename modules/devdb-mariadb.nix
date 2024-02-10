{ config, pkgs, ... }:

{
  boot.isContainer = true;
  networking.firewall.allowedTCPPorts = config.services.mysql.settings.mysqld.port;
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialScript = pkgs.writeText "devmysql-init.sql" ''
      CREATE USER IF NOT EXISTS 'dev'@'localhost'
        IDENTIFIED BY 'dev';
      GRANT ALL
        ON *.*
        TO 'dev'@'localhost'
        WITH GRANT OPTION;

      CREATE USER IF NOT EXISTS 'dev'@'%'
        IDENTIFIED BY 'dev';
      GRANT ALL
        ON *.*
        TO 'dev'@'%'
        WITH GRANT OPTION;
    '';
    settings = {
      mysqld = {
        skip_networking = 0;
        skip_bind_address = true;
      };
    };
  };
}
