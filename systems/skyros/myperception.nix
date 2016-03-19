{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.myperception;

  logbackConf = ''
  <?xml version="1.0" encoding="UTF-8" ?>
  <configuration scan="true">
    <!--Daily rolling file appender -->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
      <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <FileNamePattern>${cfg.baseDir}/log/publet.%d{yyyy-MM-dd}.log</FileNamePattern>
      </rollingPolicy>
      <layout class="ch.qos.logback.classic.PatternLayout">
        <pattern>%d{yyyy-MM-dd HH:mm:ss} %level [%thread{1}] %logger{36} - %msg%n</pattern>
      </layout>
    </appender>
    <logger name="org.eknet.publet" level="${if cfg.debug then "debug" else "info"}"/>
    <root level="info">
      <appender-ref ref="FILE" />
    </root>
  </configuration>
  '';

  serverProperties = ''
  publet.server.port=${builtins.toString cfg.bindPort}
  publet.server.bindAddress=${cfg.bindHost}
  publet.server.shutdownPort=${builtins.toString (cfg.bindPort + 1)}
  '';

  startScript = ''
  #!${pkgs.bash}/bin/bash -e
  LOC=`locale -a | grep -i utf8 | head -n1`
  if [ -n "$LOC" ]; then
    export LC_ALL=$LOC
  fi

  # find working dir and cd into it
  cd `dirname $0`/..

  JAVA_OPTS="${cfg.javaOpts} -jar \
   -Djava.io.tmpdir=${cfg.baseDir}/temp \
   -Dlogback.configurationFile=${cfg.baseDir}/etc/logback.xml"
  ${pkgs.jre}/bin/java $JAVA_OPTS bin/publet-server.jar --start
  cd -
  '';

in {

  ## interface
  options = {
    services.myperception = {
      enable = mkOption {
        default = false;
        description = "Whether to enable myperception.";
      };

      debug = mkOption {
        default = false;
        description = "Set log-level to DEBUG.";
      };

      baseDir = mkOption {
        default = "/var/data/myperception";
        description = "Location where Publet stores configuration and logfiles";
      };

      javaOpts = mkOption {
        default = "-Xmx512m -server -Djava.awt.headless=true";
        description = "Additional parameters to pass to the Java Virtual Machine that runs Publet.";
      };

      bindHost = mkOption {
        default = "127.0.0.1";
        description = "The host or ip where publet http can bind to.";
      };

      bindPort = mkOption {
        default = 10100;
        description = "The port where publet http can bind to.";
      };
    };
  };

  ## implementation
  config = mkIf config.services.myperception.enable {
    # users.extraGroups = singleton {
    #   name = "publet";
    #   gid = config.ids.gids.publet;
    # };

    # users.extraUsers = singleton {
    #   name = "publet";
    #   uid = config.ids.uids.publet;
    #   extraGroups = ["publet"];
    #   description = "Publet daemon user.";
    # };

    environment.systemPackages = [ pkgs.publet ];

    systemd.services.myperception = {
      description = "Publet server for myperception.de";
      after = ["networking.target"];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${cfg.baseDir}/plugins
        ln -sfn ${pkgs.publet}/webapp ${cfg.baseDir}/webapp

        mkdir -p ${cfg.baseDir}/{bin,log,etc,plugins,var,temp}
        chown publet:publet ${cfg.baseDir}/{log,var,temp}

        ln -sfn ${pkgs.publet}/bin/publet-server.jar ${cfg.baseDir}/bin/publet-server.jar
        ln -sfn ${pkgs.publetSharry}/publet-sharry.jar ${cfg.baseDir}/plugins/publet-sharry.jar
        ln -sfn ${pkgs.publetQuartz}/publet-quartz.jar ${cfg.baseDir}/plugins/publet-quartz.jar

        cat > ${cfg.baseDir}/etc/logback.xml <<- "EOF"
        ${logbackConf}
        EOF

        cat > ${cfg.baseDir}/etc/server.properties <<- "EOF"
        ${serverProperties}
        EOF

        cat > ${cfg.baseDir}/bin/start-publet.sh <<- "EOF"
        ${startScript}
        EOF

        cat > ${cfg.baseDir}/etc/publet.properties <<- "EOF"
        publet.mode=production
        superadminEnabled=false
        sharry.maxFolderSize=1500MiB
        sharry.maxUploadSize=300MiB
        publet.urlBase=http://www.myperception.de
        EOF
        chmod a+x ${cfg.baseDir}/bin/start-publet.sh
      '';

      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh publet -c "${cfg.baseDir}/bin/start-publet.sh"
      '';
    };

    services.nginx.httpConfig = ''
     server {
       listen  ${config.settings.primaryIp}:80;
       server_name myperception.de www.myperception.de;
       location / {
          proxy_pass http://127.0.0.1:${builtins.toString cfg.bindPort};
          proxy_set_header X-Forwarded-For $remote_addr;
       }
     }
    '';

    services.exim4.localDomains = [ "myperception.de" ];

    services.bind = {
      zones = [
        { name = "myperception.de";
          master = true;
          file = import ../../simple-zone.nix {
            inherit pkgs lib;
            domain = "myperception.de";
            ip = config.settings.primaryIp;
            nameserver = [ config.settings.primaryNameServer ];
            cnames = [ "www" ];
            mx = if (config.settings.enableMailServer) then [{ domain = "mail."+ config.settings.primaryDomain+"."; priority = "10"; }] else [];
          };
        }
      ];
    };

  };
}
