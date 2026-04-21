{ config, pkgs, lib, ... }:
let
  cfg = config.services.rns;
in
{
  options = {
    services.rns = with lib; {
      enable = mkEnableOption "rns";
      rns-pkg = mkOption {
        type = types.package;
        default = pkgs.python3Packages.rns;
        description = "The rns package";
      };
      lxmd-pkg = mkOption {
        type = types.package;
        default = pkgs.python3Packages.lxmf;
        description = "The lxmf package";
      };
      open-ports = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to open default control ports.";
      };
      config-dir = mkOption {
        type = types.str;
        default = "/var/lib/rns";
        description = "The parent config directory";
      };
    };
  };


  config = lib.mkIf config.services.rns.enable {
    # Create a user for reticulum
    users.users.rns = {
      isNormalUser = false;
      isSystemUser = true;
      group = "rns";
      home = cfg.config-dir;
      useDefaultShell = true;
    };
    users.groups = { rns = { }; };

    environment.systemPackages = [ cfg.rns-pkg cfg.lxmd-pkg ];

    systemd.tmpfiles.rules = [
      "d '${cfg.config-dir}' 0755 rns rns - -"
    ];

    networking.firewall.allowedUDPPorts =
      lib.mkIf cfg.open-ports [ 29716 42671 ];

    systemd.services.rns = {
      enable = true;
      description = "Reticulum RNSd";
      wantedBy = [ "lmxd.target" ];
      path = [ ];
      environment = { };
      serviceConfig = {
        ExecStart = "${cfg.rns-pkg}/bin/rnsd -s";
        User = "rns";
        Group = "rns";
      };
    };

    systemd.services.lxmd = {
      enable = true;
      description = "Reticulum LXMDd";
      wantedBy = [ "multi-user.target" ];
      path = [ ];
      environment = { };
      serviceConfig = {
        ExecStart = "${cfg.lxmd-pkg}/bin/lxmd -s";
        User = "rns";
        Group = "rns";
      };
    };
  };
}
