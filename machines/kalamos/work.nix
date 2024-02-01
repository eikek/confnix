let
  username = "sdsc";
  keyFile = builtins.toPath <sshpubkey>;
in
{ config, pkgs, ... }:
{
  imports =
    [
    ];

  users.users.${username} = {
    name = username;
    isNormalUser = true;
    uid = 1020;
    createHome = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [ keyFile ];
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" "adbusers" "networkmanager" "camera" ];
    packages =
      with pkgs;
      [ libreoffice
        slack
        python3Packages.pip
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
