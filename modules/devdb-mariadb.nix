{ config, pkgs, ... }:

{ services.mysql = {
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
    extraOptions = ''
      skip-networking=0
      skip-bind-address
   '';
  };
}
