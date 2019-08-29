{ config, pkgs, ... }:

{ services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialScript = pkgs.writeText "devmysql-init.sql" ''
      CREATE USER IF NOT EXISTS 'dev' IDENTIFIED BY 'dev';
      GRANT ALL ON *.* TO 'dev'@'%';
    '';
    extraOptions = ''
      skip-networking=0
      skip-bind-address
   '';
  };
}
