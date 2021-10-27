{pkgs, config, ...}:
{

  services.openvpn.servers = {
    dev = {
      config = " config /root/openvpn/dev.ovpn ";
      autoStart = false;
    };
    stage = {
      config = " config /root/openvpn/stage.ovpn ";
      autoStart = false;
    };
  };

}
