{config, lib, pkgs, ...}:

with lib;
{
  options = {
    services.pill = {
      enable = mkOption {
        default = false;
        description = "Whether to enable pill.";
      };
    };
  };

  config = mkIf config.services.pill.enable {
    environment.systemPackages = [ pkgs.pill ];
    systemd.user.services.pill = {
      description = "pill server";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.pill}/program/pill-server";
        RestartSec = 5;
        Restart = "always";
      };
    };
  };
}
