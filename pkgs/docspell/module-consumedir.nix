{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.docspellconsumedir;
  user = if cfg.runAs == null then "docspell" else cfg.runAs;

in {

  ## interface
  options = {
    services.docspellconsumedir = {
      enable = mkOption {
        default = false;
        description = "Whether to enable docspell consume directory.";
      };

      runAs = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The user that runs the consumedir process.
        '';
      };

      watchDirs = mkOption {
        type = types.listOf types.str;
        description = "The directories to watch for new files.";
      };

      verbose = mkOption {
        type = types.bool;
        default = false;
        description = "Run in verbose mode";
      };

      deleteFiles = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to delete successfully uploaded files.";
      };

      memorize = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Set a writable directory to enable memorizing which files have been uploaded to enable skipping duplicates.";
      };

      urls = mkOption {
        type = types.listOf types.str;
        example = [ "http://localhost:7880/api/v1/open/upload/item/abced-12345-abcde-12345" ];
        description = "A list of upload urls.";
      };
    };
  };

  ## implementation
  config = mkIf config.services.docspellconsumedir.enable {

    systemd.services.docspellconsumedir =
    let
      args = (builtins.concatMap (a: ["--path" ("'" + a + "'")]) cfg.watchDirs) ++
             (if cfg.verbose then ["-v"] else []) ++
             (if cfg.deleteFiles then ["-d"] else []) ++
             (if cfg.memorize == null then [] else ["-m" ("'" + cfg.memorize + "'")]) ++
             (map (a: "'" + a + "'") cfg.urls);
      cmd = "${pkgs.docspell.tools}/bin/consumedir.sh " + (builtins.concatStringsSep " " args);
    in
    {
      description = "Docspell Consumedir";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = if cfg.memorize == null then ""
        else ''
          mkdir -p ${cfg.memorize}
          chown -R ${user} ${cfg.memorize}
        '';
      path = [ pkgs.utillinux pkgs.curl pkgs.coreutils ];

      script =
        if user == "root" then cmd
        else "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${user} -c \"${cmd}\"";
    };
  };
}
