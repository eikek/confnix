let
  username = "sdsc";
  sshkeys = import ../../secrets/ssh-keys.nix;
  chromiummod = import ../../modules/chromium-proxy.nix username;
in
{ config, pkgs, ... }:
{
  imports =
    [ chromiummod
    ];

  nix.settings.trusted-users = [ username ];

  users.users.${username} = {
    name = username;
    isNormalUser = true;
    uid = 1020;
    createHome = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ sshkeys.eike ];
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" "adbusers" "networkmanager" "camera" "keys" ];
    packages =
      with pkgs;
      [
        libreoffice
        slack
        zoom-us
        squirrel-sql
        kind
        kubectx
        kubectl
        kubernetes
        kubernetes-helm
        k9s
        kail
        jdk17
        sops
      ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
