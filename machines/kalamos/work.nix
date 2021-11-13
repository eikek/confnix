let
  username = "tundra";
  keyFile = builtins.toPath <sshpubkey>;
in
{ config, pkgs, ... }:
{
  imports =
    [ ./keybase.nix
    ];

  users.users.${username} = {
    name = username;
    isNormalUser = true;
    uid = 1010;
    createHome = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [ keyFile ];
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" "adbusers" "networkmanager" "camera" ];
    packages =
      let
        dynamodb-start = pkgs.writeShellScriptBin "dynamodb-start" ''
          docker run -v ~eike/workspace/dynamodb:/dynamodb_local_db \
             -p 8000:8000 \
             --name dynamodb \
             --rm \
             -d amazon/dynamodb-local:latest
        '';
      in
      with pkgs;
      [ libreoffice
        slack
        keybase-gui
        awscli2
        gopass
        python3Packages.pip
        coursier
        dynamodb-start
      ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openvpn.servers = {
    dev = {
      config = " config /root/openvpn/${username}/dev.ovpn ";
      autoStart = false;
    };
  };
}
