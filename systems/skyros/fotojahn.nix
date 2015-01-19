{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.fotojahn;

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
    services.fotojahn = {
      enable = mkOption {
        default = false;
        description = "Whether to enable fotojahn.";
      };

      debug = mkOption {
        default = false;
        description = "Set log-level to DEBUG.";
      };

      baseDir = mkOption {
        default = "/var/data/fotojahn";
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
        default = 10200;
        description = "The port where publet http can bind to.";
      };
    };
  };

  ## implementation
  config = mkIf config.services.fotojahn.enable {
    environment.systemPackages = [ pkgs.publet ];

    systemd.services.fotojahn = {
      description = "Publet server for fotojahn.com";
      after = ["networking.target"];

      preStart = ''
        mkdir -p ${cfg.baseDir}
        ln -sfn ${pkgs.publet}/webapp ${cfg.baseDir}/webapp

        mkdir -p ${cfg.baseDir}/{bin,log,etc,plugins,var,temp}
        chown publet:publet ${cfg.baseDir}/{log,var,temp}

        ln -sfn ${pkgs.publet}/bin/publet-server.jar ${cfg.baseDir}/bin/publet-server.jar

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
        applicationName=fotostudio-jahn.com
        superadminEnabled=false
        publet.urlBase=http://www.fotostudio-jahn.com
        smtp.host=localhost
        smtp.port=25
        smtp.username=
        smtp.password=
        defaultReceiver=post@fotostudio-jahn.com
        thumbnail.maxDiskSize=700MiB
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
       server_name fotostudio-jahn.com www.fotostudio-jahn.com;
       location / {
          proxy_pass http://127.0.0.1:${builtins.toString cfg.bindPort};
          proxy_set_header X-Forwarded-For $remote_addr;
       }
     }
    '';
  };
}
