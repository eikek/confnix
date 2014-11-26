{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.sitebag;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
  sitebagUser = "sitebag";
  confFile = ''
  include "application"
  akka {
    ${if cfg.porter.mode == "remote" then ''
    actor {
      provider = "akka.remote.RemoteActorRefProvider"
    }
    remote {
      enabled-transports = [ "akka.remote.netty.tcp" ]
      netty.tcp {
        hostname = "127.0.0.1"
        port = 7557
      }
    }
    '' else ""}
    loggers = ["akka.event.slf4j.Slf4jLogger"]
    loglevel = "DEBUG"
  }
  spray.can {
    # follow redirects by default. see
    # http://spray.io/documentation/1.2.1/spray-can/http-client/#redirection-following
    host-connector.max-redirects = 10
    ${if cfg.proxy.enable then ''
    client {
      proxy {
        http {
          host = ${cfg.proxy.host}
          port = ${str cfg.proxy.port}
        ##  non-proxy-hosts = ["*.direct-access.net"]
        }
      }
    }
    '' else ""}
  }
  porter {
    mode = "${cfg.porter.mode}"
    realm = "${cfg.porter.realm}"
    ${if cfg.porter.mode == "embedded" then ''
    embedded {
        telnet.enabled = ${str cfg.porter.embedded.telnet.enable}
        telnet.host = "${cfg.porter.embedded.telnet.host}"
        telnet.port = ${str cfg.porter.embedded.telnet.port}
      }
    '' else ""}
    ${if cfg.porter.mode == "remote" then ''
    remote {
        url = "${cfg.porter.remote.url}"
      }
    '' else ""}
  }
  sitebag {
    mongodb-url = "${cfg.mongodbUrl}"
    dbname = "${cfg.databaseName}"
    bind-host = "${cfg.bindHost}"
    bind-port = ${str cfg.bindPort}
    url-base = "${cfg.urlBase}"
    trust-all-ssl = ${str cfg.trustAllSsl}
    always-save-document = ${str cfg.alwaysSaveDocument}
    enable-web-ui = ${str cfg.webui.enable}
    extractors: [
      { class: "org.eknet.sitebag.content.HtmlExtractor", params: {} }
      { class: "org.eknet.sitebag.content.TextplainExtractor", params: {} }
    ]
    webui {
      brandname = "${cfg.webui.brandName}"
      enable-change-password = ${str cfg.webui.enableChangePasswordForm}
      enable-highlightjs = ${str cfg.webui.enableHighlightJs}
      highlightjs-theme = "${cfg.webui.highlightJsTheme}"
    }
  }
  '';

  logbackConf = ''
  <?xml version="1.0" encoding="UTF-8" ?>
  <configuration scan="true">
    <!--Daily rolling file appender -->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
      <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <FileNamePattern>${cfg.baseDir}/log/sitebag.%d{yyyy-MM-dd}.log</FileNamePattern>
      </rollingPolicy>
      <layout class="ch.qos.logback.classic.PatternLayout">
        <pattern>%d{yyyy-MM-dd HH:mm:ss} %level [%thread{1}] %logger{36} - %msg%n</pattern>
      </layout>
    </appender>
    <logger name="org.eknet.sitebag" level="${if cfg.debug then "debug" else "info"}"/>
    <root level="info">
      <appender-ref ref="FILE" />
    </root>
  </configuration>
  '';

in {

  ## interface
  options = {
    services.sitebag = {
      enable = mkOption {
        default = false;
        description = "Whether to enable sitebag.";
      };

      debug = mkOption {
        default = false;
        description = "Set log-level to DEBUG.";
      };

      baseDir = mkOption {
        default = "/var/sitebag";
        description = "Location where Sitebag stores configuration and logfiles";
      };

      javaOpts = mkOption {
        default = "-Xmx512m -server -Djava.awt.headless=true";
        description = "Additional parameters to pass to the Java Virtual Machine that runs Sitebag.";
      };

      configFile = mkOption {
        default = confFile;
        description = "Sitebag conf file that overrides the generated one.";
      };

      logbackConfig = mkOption {
        default = logbackConf;
        description = "Logback configuration overriding the default one.";
      };

      makeAdmin = mkOption {
        default = true;
        description = "Create an initial admin/admin account.";
      };

      mongodbUrl = mkOption {
        default = mongodb://localhost:27017/;
        description = "The mongodb url (without db name) that sitebag can use.";
      };

      databaseName = mkOption {
        default = "sitebagdb";
        description = "The mongodb database name.";
      };

      bindHost = mkOption {
        default = "0.0.0.0";
        description = "The host or ip where sitebag http can bind to.";
      };

      bindPort = mkOption {
        default = 9995;
        description = "The port where sitebag http can bind to.";
      };

      urlBase = mkOption {
        default = "http://${cfg.bindHost}:${str cfg.bindPort}/";
        description = "The base url part to reach sitebag. Sitebag calculates links based on this url";
      };

      trustAllSsl = mkOption {
        default = true;
        description = "Whether to allow downloading pages from untrusted ssl connections.";
      };

      alwaysSaveDocument = mkOption {
        default = false;
        description = ''If sitebag cannot cope with a given document
          (e.g. pdfs or other binary formats), it is simply discarded. But if this is true,
          sitebag nevertheless stores the original document in the database.'';
      };

      proxy = {
        enable = mkOption {
          default = false;
          description = "Enable custom proxy settings. Note that this only works for http, not for https. By default, systems proxy settings are used.";
        };
        host = mkOption {
          default = "";
          description = "The proxy host to use.";
        };
        port = mkOption {
          default = 8080;
          description = "The porxy port to use.";
        };
      };

      porter = {
        mode = mkOption {
          default = "embedded";
          description = "If `embedded' sitebag's internal user management is used. A
             value of `remote' specifies to use an external porter server for authentication.";
        };

        realm = mkOption {
          default = "default";
          description = "The realm name to use.";
        };

        remote = {
          url = mkOption {
            default = "akka.tcp://porter@127.0.0.1:4554/user/porter/api";
            description = "The url where akka can lookup the porter actor via remoting.";
          };
        };

        embedded = {
          telnet = {
            enable = mkOption {
              default = false;
              description = "Enable porter's admin console, available via telnet.";
            };

            host = mkOption {
              default = "localhost";
              description = "The host where telnet server binds to.";
            };

            port = mkOption {
              default = 9990;
              description = "The port where the telnet server binds to.";
            };
          };
        };
      };

      webui = {
        enable = mkOption {
          default = true;
          description = "Whether to enable the web interface.";
        };

        brandName = mkOption {
          default = "Sitebag";
          description = "The brand name, which is displayed in the upper left of every page.";
        };

        enableChangePasswordForm = mkOption {
          default = (if cfg.porter.mode == "embedded" then true else false);
          description = "Whether to display a 'change password form'. It may be desired to disable it when using external user management.";
        };

        enableHighlightJs = mkOption {
          default = true;
          description = "Whether to include highlightjs in every page for source code syntax highlighting.";
        };

        highlightJsTheme = mkOption {
          default = "default";
          description = "The highlightjs theme to use. Choose one from https://github.com/isagalaev/highlight.js/tree/master/src/styles";
        };
      };
    };
  };

  ## implementation
  config = mkIf config.services.sitebag.enable {
    users.extraGroups = singleton {
      name = "sitebag";
      gid = config.ids.gids.sitebag;
    };

    users.extraUsers = singleton {
      name = sitebagUser;
      uid = config.ids.uids.sitebag;
      extraGroups = ["sitebag"];
      description = "Sitebag daemon user.";
    };

    environment.systemPackages = [ pkgs.sitebag ];

    jobs.sitebag = {
      description = "Sitebag server";
      startOn = "started networking";
      daemonType = "daemon";

      preStart = ''
        mkdir -p ${cfg.baseDir}
        ln -sfn ${pkgs.sitebag}/lib ${cfg.baseDir}/lib

        mkdir -p ${cfg.baseDir}/{bin,log,etc}
        chown ${sitebagUser}:sitebag ${cfg.baseDir}/log

        touch ${cfg.baseDir}/etc/{sitebag.conf,logback.xml}
        cat > ${cfg.baseDir}/etc/sitebag.conf << EOF
        ${cfg.configFile}
        EOF
        cat > ${cfg.baseDir}/etc/logback.xml << EOF
        ${cfg.logbackConfig}
        EOF

        cp ${pkgs.sitebag}/bin/start-sitebag.sh ${cfg.baseDir}/bin
      '';

      exec = "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${sitebagUser} -c \"JAVA_HOME=${pkgs.jdk} ${cfg.baseDir}/bin/start-sitebag.sh -c ${cfg.baseDir}/etc/sitebag.conf -l ${cfg.baseDir}/etc/logback.xml ${if cfg.makeAdmin then "-a" else ""}\" &";
    };
  };
}
