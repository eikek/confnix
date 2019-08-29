{pkgs, config, ...}:
{

  services.openvpn.servers = {
    officeVPN = {
      config = " config /root/openvpn/vpfwblue.bluecare.ch.ovpn ";
      autoStart = false;
    };
  };

}
