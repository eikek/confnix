{ config, pkgs, ... }:
let
  extif = "enp1s0";
in
{

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = extif;
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${extif} -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${extif} -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/root/wg-keys/private";

      fwMark = "0xce6166";

      peers = [
        # List of allowed peers.
        {
          name = "myself";
          publicKey = "fDNjzBSDsMqhg/CkS8JF+xUrm4RKnVYmMxCkSwuVOVw=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        {
          name = "phone";
          publicKey = "dmYGFAQYuYp0sf76hgXtdDpRNqu2aW6F+0iINQjMERw=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };

}
