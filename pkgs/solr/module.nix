{ config
, lib
, pkgs
, ...
}:
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
      bindAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "The address to bind to";
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
      useDefaultShell = true;
    };
    users.groups = { solr = { }; };

    # to allow playing with the solr cli
    environment.systemPackages = [ pkgs.solr ];

    environment.etc = { solr = { source = "${pkgs.solr}/server/solr"; }; };

    # Create directories for storage
    systemd.tmpfiles.rules = [
      "d /var/solr 0755 solr solr - -"
      "d /var/solr/data 0755 solr solr - -"
      "d /var/solr/logs 0755 solr solr - -"
    ];

    systemd.services.solr = {
      enable = true;
      description = "Apache Solr";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ solr lsof coreutils procps gawk ];
      environment = {
        SOLR_PORT = toString cfg.port;
        SOLR_JETTY_HOST = cfg.bindAddress;
        SOLR_HEAP = "${toString cfg.heap}m";
        SOLR_PID_DIR = "/var/solr";
        SOLR_HOME = "${cfg.home-dir}";
        SOLR_LOGS_DIR = "/var/solr/logs";
      };
      serviceConfig = {
        ExecStart = "${pkgs.solr}/bin/solr start -f -Dsolr.modules=analysis-extras";
        ExecStop = "${pkgs.solr}/bin/solr stop";
        LimitNOFILE = "65000";
        LimitNPROC = "65000";
        User = "solr";
        Group = "solr";
      };
    };
  };
}
