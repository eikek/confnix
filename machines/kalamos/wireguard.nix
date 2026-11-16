{ config, pkgs, ... }:
  let
    extif = "enp2s0";
  in
  {
    # key generation:
    # umask 077
    # wg genkey | tee privatekey | wg pubkey > publickey


    # enable NAT
    # networking.nat.enable = true;
    # networking.nat.externalInterface = extif;
    # networking.nat.internalInterfaces = [ "wg0" ];
    networking.firewall = {
      allowedUDPPorts = [ 51820 ];
    };

    networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [ "10.20.0.2/24" ];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = 51820;

        privateKeyFile = "/root/wg/privatekey";

        fwMark = "0xce6166";

        peers = [
          # List of allowed peers.
          {
            name = "eknet.org";
            publicKey = "GKvbe/7EUZQO/kmVF6YGQSvjxs9rzOPSxW8Acy4T2AY=";
            endpoint = "159.69.107.23:51820";
            allowedIPs = [ "10.20.0.1/32" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };

  }
