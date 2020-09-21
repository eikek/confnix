# Adds a self-created root certificate to the system's truststore.
# This is used to sign certificates for local development.

{ config, lib, pkgs, ... }:

{

  # for firefox/chromium you must import this in their "certificate
  # authority" settings
  security.pki.certificateFiles =
    [ ./certs/rootCA.pem
    ];

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    commonHttpConfig = ''
      # Keep in sync with https://ssl-config.mozilla.org/#server=nginx&config=intermediate
      ssl_session_timeout 1d;
      ssl_session_cache shared:SSL:10m;
      # Breaks forward secrecy: https://github.com/mozilla/server-side-tls/issues/135
      ssl_session_tickets off;
      # We don't enable insecure ciphers by default, so this allows
      # clients to pick the most performant, per https://github.com/mozilla/server-side-tls/issues/260
      ssl_prefer_server_ciphers off;
      # OCSP stapling
      ssl_stapling on;
      ssl_stapling_verify on;
    '';
    virtualHosts = {
      "localhost" = {
        serverName = "localhost";
        forceSSL = true;
        sslCertificate = ./certs/server.crt;
        sslCertificateKey = ./certs/server.key;
        locations."/" = {
           proxyPass = "http://127.0.0.1:7880";
           proxyWebsockets = true;
           extraConfig = ''
             client_max_body_size 105M;
             proxy_send_timeout   300s;
             proxy_read_timeout   300s;
             proxy_buffering off;
             send_timeout         300s;
           '';
        };
      };
    };
  };
}
