{ pkgs, config, ... }:
{

  services.openvpn.servers = {
    homeVPN = {
      config = " config /root/openvpn/home.ovpn ";
      autoStart = false;
    };
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      autostart = false;
      address = [ "10.100.0.3/32"  ];
      #dns = [ "10.100.0.1" ];
      privateKeyFile = "/root/wireguard/myself.key";

      peers = [
        {
          publicKey = "2eXVN6SgSjf6NrlSk111y5GBfTFD2VuW0eY6rBszfVc=";
          #presharedKeyFile = "/root/wireguard-keys/preshared_from_peer0_key";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "mgn.daheim.site:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
