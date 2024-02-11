{ config, pkgs, ... }:
let
  full-text-search = {
    enabled = true;
    solr.url = "http://localhost:${toString config.services.solr.port}/solr/docspell";
  };
in
{

  imports = import ../pkgs/modules.nix;

  services.docspell-joex = {
    enable = true;
    waitForTarget = "solr-init.target";
    bind.address = "0.0.0.0";
    base-url = "http://localhost:7878";
    jvmArgs = [ "-J-Xmx1536M" ];
    jdbc = {
      url = "jdbc:postgresql://localhost:5432/docspell";
      user = "docspell";
      password = "docspell";
    };
    inherit full-text-search;
  };

  services.docspell-restserver = {
    enable = true;
    bind.address = "0.0.0.0";
    integration-endpoint = {
      enabled = true;
      http-header = {
        enabled = true;
        header-value = "test123";
      };
    };
    auth = {
      server-secret = "b64:TVpmTkkzc1dSLVg3bEhudFctdjE1Zz09";
    };
    backend = {
      signup = {
        mode = "open";
        new-invite-password = "dsinvite";
        invite-time = "30 days";
      };
      jdbc = {
        url = "jdbc:postgresql://localhost:5432/docspell";
        user = "docspell";
        password = "docspell";
      };
    };
    inherit full-text-search;
  };

  networking.firewall = {
    allowedTCPPorts = [ 7880 7878 ];
  };

  # install postgresql and initially create user/database
  services.postgresql =
    let
      pginit = pkgs.writeText "pginit.sql" ''
        CREATE USER docspell WITH PASSWORD 'docspell' LOGIN CREATEDB;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO docspell;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO docspell;
        CREATE DATABASE DOCSPELL OWNER 'docspell';
      '';
    in
    {
      enable = true;
      package = pkgs.postgresql_12;
      enableTCPIP = true;
      initialScript = pginit;
      port = 5432;
      authentication = ''
        host  all  all 0.0.0.0/0 md5
      '';
    };

  services.solr = {
    enable = true;
  };

  # This is needed to run solr script as user solr
  users.users.solr.useDefaultShell = true;
  users.users.docspell.isSystemUser = pkgs.lib.mkForce true;

  systemd.services.solr-init =
    let
      solrPort = toString config.services.solr.port;
      initSolr = ''
        if [ ! -f ${config.services.solr.stateDir}/docspell_core ]; then
          while ! echo "" | ${pkgs.inetutils}/bin/telnet localhost ${solrPort}
          do
             echo "Waiting for SOLR become ready..."
             sleep 1.5
          done
          ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh solr -c "${pkgs.solr}/bin/solr create_core -c docspell -p ${solrPort}";
          touch ${config.services.solr.stateDir}/docspell_core
        fi
      '';
    in
    {
      script = initSolr;
      after = [ "solr.target" ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "solr.target" ];
      description = "Create a core at solr";
    };

  environment.systemPackages =
    [
      pkgs.docspell.tools
    ];

}
