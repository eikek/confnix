{ config, pkgs, ... }:
{

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    extensions = ps: [ps.postgis];
    enableTCPIP = true;
    # initialScript = pginit;
    # authentication = ''
    #   host  all  all 0.0.0.0/0 md5
    # '';
    settings = {
      "log_min_duration_statement" = 100;
      "port" = 5432;
    };
  };

  networking.firewall.allowedTCPPorts = [5432];

}
