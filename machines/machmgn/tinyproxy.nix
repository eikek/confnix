{ config, ... }:

{
  services.tinyproxy = {
    enable = true;
    settings = {
      Port = 24812;
      Listen = "0.0.0.0";
      Timeout = 600;
      Allow = [ "127.0.0.1" "192.168.1.229" "212.51.159.34" "129.132.155.23" ];
      LogLevel = "Info";
      SysLog = "On";
      MaxClients = 100;
      MinSpareServers = 5;
      MaxSpareServers = 20;
      StartServers = 10;
      DisableViaHeader = "Yes";
      MaxRequestsPerChild = 0;
      ConnectPort = [ 443 563 ];
      BasicAuth = "ohKahphevug0yox1ooy ri6einee2ac8QuooY4u";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 24812 ];
  };

}
