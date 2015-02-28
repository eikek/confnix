{ config, pkgs, lib, ... }:
with config;
with lib;
{
  options = {
    services.bindExtra = {
      subdomains = mkOption {
        default = [ "ns" ];
        description = "The subdomains to create for the <literal>primaryDomain</literal>";
      };
    };
  };

  config = mkIf settings.enableBind {
    services.bindExtra.subdomains = ["ns"];
    services.bind = {
      enable = settings.enableBind;
      ipv4Only = true;
      zones = [
        { name = settings.primaryDomain;
          master = true;
          file = import ../../simple-zone.nix {
            inherit pkgs lib;
            domain = settings.primaryDomain;
            ip = settings.primaryIp;
            nameserver = [ settings.primaryNameServer "STATIC.134.107.40.188.CLIENTS.YOUR-SERVER.DE" ];
            arecords = config.services.bindExtra.subdomains ++ (if (settings.enableMailServer) then ["mail"] else []);
            mx = if (settings.enableMailServer) then [{ domain = "mail"; priority = "10"; }] else [];
          };
        }
      ];
    };
  };
}
