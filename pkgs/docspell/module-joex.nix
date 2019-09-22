{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.docspelljoex;
  user = if cfg.runAs == null then "root" else cfg.runAs;

  configFile = pkgs.writeText "docspell-joex.conf" ''
    docspell.joex {

      # This is the id of this node. If you run more than one server, you
      # have to make sure to provide unique ids per node.
      app-id = "${cfg.appId}"


      # This is the base URL this application is deployed to. This is used
      # to register this joex instance such that docspell rest servers can
      # reach them
      base-url = "${cfg.baseUrl}"

      # Where the REST server binds to.
      #
      # JOEX provides a very simple REST interface to inspect its state.
      bind {
        address = "${cfg.bindHost}"
        port = ${toString cfg.bindPort}
      }

      # The database connection.
      #
      # By default a H2 file-based database is configured. You can provide
      # a postgresql or mariadb connection here. When using H2 use the
      # PostgreSQL compatibility mode and AUTO_SERVER feature.
      #
      # It must be the same connection as the rest server is using.
      jdbc {
        url = "${cfg.jdbc.url}"
        user = "${cfg.jdbc.user}"
        password = "${cfg.jdbc.password}"
      }

      # Configuration for the job scheduler.
      scheduler {

        # Each scheduler needs a unique name. This defaults to the node
        # name, which must be unique, too.
        name = ${cfg.appId}

        # Number of processing allowed in parallel.
        pool-size = ${toString cfg.parallel}

        # A counting scheme determines the ratio of how high- and low-prio
        # jobs are run. For example: 4,1 means run 4 high prio jobs, then
        # 1 low prio and then start over.
        counting-scheme = "${cfg.countingScheme}"

        # How often a failed job should be retried until it enters failed
        # state. If a job fails, it becomes "stuck" and will be retried
        # after a delay.
        retries = ${toString cfg.retries}

        # The delay until the next try is performed for a failed job. This
        # delay is increased exponentially with the number of retries.
        retry-delay = "1 minute"

        # The queue size of log statements from a job.
        log-buffer-size = 500

        # If no job is left in the queue, the scheduler will wait until a
        # notify is requested (using the REST interface). To also retry
        # stuck jobs, it will notify itself periodically.
        wakeup-period = "30 minutes"
      }

      # Configuration of text extraction
      #
      # Extracting text currently only work for image and pdf files. It
      # will first runs ghostscript to create a gray image from a
      # pdf. Then unpaper is run to optimize the image for the upcoming
      # ocr, which will be done by tesseract. All these programs must be
      # available in your PATH or the absolute path can be specified
      # below.
      extraction {
        #allowed-content-types = [ "application/pdf", "image/jpeg", "image/png" ]

        page-range {
          begin = ${toString cfg.extractPageStartLimit}
        }

        # The ghostscript command.
        ghostscript {
          command {
            program = "${cfg.ghostscript.command}"
            timeout = "${cfg.ghostscript.timeout}"
          }
          working-dir = "${cfg.extractionTmpDir}"
        }

        # The unpaper command.
        unpaper {
          command {
            program = "${cfg.unpaper.command}"
            timeout = "${cfg.unpaper.timeout}"
          }
        }

        # The tesseract command.
        tesseract {
          command {
            program = "${cfg.tesseract.command}"
            timeout = "${cfg.tesseract.timeout}"
          }
        }
      }
    }
  '';
in {

  ## interface
  options = {
    services.docspelljoex = {
      enable = mkOption {
        default = false;
        description = "Whether to enable docspell docspell job executor.";
      };

      runAs = mkOption {
        type = types.nullOr types.string;
        default = null;
        description = ''
          The user that runs the docspell server process.
        '';
      };

      appId = mkOption {
        type = types.string;
        default = "docspell-joex1";
        description = "The node id. Must be unique across all docspell nodes.";
      };

      baseUrl = mkOption {
        type = types.string;
        default = "http://localhost:7878";
        description = "The base url where attentive is deployed.";
      };

      bindHost = mkOption {
        type = types.string;
        default = "localhost";
        description = "The address to bind the webserver";
      };
      bindPort = mkOption {
        type = types.int;
        default = 7878;
        description = "The port to bind the web server";
      };
      extractionTmpDir = mkOption {
        type = types.string;
        default = "/tmp/docspell-extraction";
        description = "Directory where the extraction processes can put their temp files";
      };
      extractPageStartLimit = mkOption {
        type = types.int;
        default = 10;
        description = ''
          The limit of pages to extract text from, starting from 1. Avoids endless processing
          if PDF files with hundreds of pages are submitted. Set to -1 to disable this limit.
        '';
      };
      ghostscript = mkOption {
        type = types.submodule ({
          options = {
            command = mkOption {
              type = types.string;
              default = "${pkgs.ghostscript}/bin/gs";
              description = "The path to the ghostscript executable";
            };
            timeout = mkOption {
              type = types.string;
              default = "5 minutes";
              description = "The timeout when running ghostscript.";
            };
          };
        });
        default = {
          command = "${pkgs.ghostscript}/bin/gs";
          timeout = "5 minutes";
        };
      };
      unpaper = mkOption {
        type = types.submodule ({
          options = {
            command = mkOption {
              type = types.string;
              default = "${pkgs.unpaper}/bin/unpaper";
              description = "The path to the unpaper executable";
            };
            timeout = mkOption {
              type = types.string;
              default = "5 minutes";
              description = "The timeout when running unpaper.";
            };
          };
        });
        default = {
          command = "${pkgs.unpaper}/bin/unpaper";
          timeout = "5 minutes";
        };
      };
      tesseract = mkOption {
        type = types.submodule ({
          options = {
            command = mkOption {
              type = types.string;
              default = "${pkgs.tesseract4}/bin/tesseract";
              description = "The path to the tesseract executable";
            };
            timeout = mkOption {
              type = types.string;
              default = "5 minutes";
              description = "The timeout when running tesseract.";
            };
          };
        });
        default = {
          command = "${pkgs.tesseract4}/bin/tesseract";
          timeout = "5 minutes";
        };
      };
      jdbc = mkOption {
        type = types.submodule ({
          options = {
            url = mkOption {
              type = types.string;
              default = "jdbc:h2:///tmp/docspell-demo.db;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;AUTO_SERVER=TRUE";
              description = ''
                The URL to the database. By default a file-based database is
                used. It should also work with mariadb and postgresql.

                Examples:
                   "jdbc:mariadb://192.168.1.172:3306/docspell"
                   "jdbc:postgresql://localhost:5432/docspell"
                   "jdbc:h2:///home/dbs/docspell.db;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;AUTO_SERVER=TRUE"

              '';
            };
            user = mkOption {
              type = types.string;
              default = "sa";
              description = "The user name to connect to the database.";
            };
            password = mkOption {
              type = types.string;
              default = "";
              description = "The password to connect to the database.";
            };
            poolSize = mkOption {
              type = types.int;
              default = 10;
              description = "The database pool size.";
            };
          };
        });
        default = {
          url = "jdbc:h2:///tmp/docspell-demo.db;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;AUTO_SERVER=TRUE";
          user = "sa";
          password = "";
          poolSize = 10;
        };
        description = "Database connection settings";
      };
      parallel = mkOption {
        type = types.int;
        default = 2;
        description = "The number of jobs allowed to execute in parallel.";
      };
      retries = mkOption {
        type = types.int;
        default = 5;
        description = "The number of retry attempts.";
      };
      countingScheme = mkOption {
        type = types.string;
        default = "4,1";
        description = "The counting scheme for the job scheduler.";
      };

    };
  };

  ## implementation
  config = mkIf config.services.docspelljoex.enable {

    networking.firewall.allowedTCPPorts = [ cfg.bindPort ];

    systemd.services.docspelljoex =
    let
      cmd = "${pkgs.docspell.joex}/bin/docspell-joex -Dlogback.configurationFile=${./logback.xml} ${configFile}";
    in
    {
      description = "Docspell Joex";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gawk ];
      preStart = ''
      '';

      script =
        if user == "root" then cmd
        else "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${user} -c \"${cmd}\"";
    };
  };
}
