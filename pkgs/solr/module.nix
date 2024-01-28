{config, lib, pkgs, ...}:
let
  cfg = config.services.solr;
in
{

  ## interface
  options = with lib; {
    services.solr = {
      enable = mkOption {
        default = false;
        description = "Whether to enable solr.";
      };
      port = mkOption {
        type = types.int;
        default = 8983;
        description = "The port solr is listening on.";
      };
      heap = mkOption {
        type = types.int;
        default = 2048;
        description = "The heap setting in megabytes";
      };
      home-dir = mkOption {
        type = types.str;
        default = "/var/solr/data";
        description = "Home dir of solr, to store the data";
      };
    };
  };


  ## implementation
  config = lib.mkIf config.services.solr.enable {
    # Create a user for solr
    users.users.solr = {
      isNormalUser = false;
      isSystemUser = true;
      group = "solr";
    };
    users.groups = {
      solr = { };
    };

    # Create directories for storage
    systemd.tmpfiles.rules =
      [
        "d /var/solr 0755 solr solr - -"
        "d /var/solr/data 0755 solr solr - -"
        "d /var/solr/logs 0755 solr solr - -"
        "L /var/solr/data/solr.xml - - - - /etc/solr/solr.xml"
        "L /var/solr/data/zoo.cfg - - - - /etc/solr/zoo.cfg"
        "L /var/solr/log4j2.xml - - - - /etc/solr/log4j2.xml"
      ];

    systemd.services.solr = {
      enable = true;
      description = "Apache Solr";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        solr
        lsof
        coreutils
        procps
        gawk
      ];
      environment = {
        SOLR_PORT = toString cfg.port;
        SOLR_HEAP= "${toString cfg.heap}m";
        SOLR_PID_DIR = "/var/solr";
        SOLR_HOME = "${cfg.home-dir}";
        LOG4J_PROPS = "/var/solr/log4j2.xml";
        SOLR_LOGS_DIR = "/var/solr/logs";
      };
      serviceConfig = {
        ExecStart = "${pkgs.solr}/bin/solr start -f";
        ExecStop = "${pkgs.solr}/bin/solr stop";
        LimitNOFILE = "65000";
        LimitNPROC = "65000";
        User = "solr";
        Group = "solr";
      };
    };
  };
}
