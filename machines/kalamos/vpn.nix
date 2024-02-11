{ pkgs, config, ... }:
{

  services.openvpn.servers = {
    homeVPN = {
      config = " config /root/openvpn/home.ovpn ";
      autoStart = false;
    };
  };

}
