{ config, pkgs, lib, ... }:
with config;
with lib;
let
  cfg = config.services.pages;
  index = pkgs.writeTextFile {
    name = "pages-index.html";
    destination = "/pages-index/index.html";
    text = ''
      <html>
      <head>
        <title>Pages Index</title>
        <meta  http-equiv="Content-Type" content="text/html;charset=utf-8" />
      </head>
      <body>
      <h1>Read offline…</h1>
      <ul>
      ${concatMapStringsSep "\n" (src: "<li><a href='${src.location}/${if (builtins.hasAttr ''file'' src) then src.file else ''''}'>${src.name}</a></li>") cfg.sources}
      </ul>
      </body>
      </html>
    '';
  };
  locations = concatMapStringsSep "\n" (src: "location /${src.location}/ { alias ${src.root}; }") cfg.sources;
in
{

  options = {
    services.pages = {
      enable = mkOption {
        default = false;
        description = "Enable offline pages.";
      };

      serverName = mkOption {
        default = "pages";
        description = "The server name to use.";
      };

      sources = mkOption {
        default = [];
        description = "Packages providing some content.";
        example = ''[{ name = "Scala Docs"; location = "scaladocs"; root = pkgs.scaladoc; }]'';
      };
    };
  };

  config = mkIf cfg.enable {
    networking.extraHosts = "127.0.0.1 " + cfg.serverName;

    services.nginx =  {
      enable = true;
      httpConfig = ''
        include       ${pkgs.nginx}/conf/mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        keepalive_timeout  65;
        gzip on;
        gzip_min_length 1024;
        gzip_buffers 4 32k;
        gzip_types text/plain text/html application/x-javascript text/javascript text/xml text/css;

        server {
          listen 80;
          server_name ${cfg.serverName};
          index index.html;
          location / {
            alias ${index}/pages-index/;
          }
          ${locations}
        }
      '';
    };
  };
}
