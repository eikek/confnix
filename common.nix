{ config, pkgs, ... }:
{
  imports = import ./modules/module-list.nix;

  nix.extraOptions = "auto-optimise-store = true";

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 22 ];
  };

  services.openssh.enable = true;
  services.ntp.enable = true;

  programs = {
    ssh.startAgent = false;
    bash.enableCompletion = true;
    zsh.enable = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = import ./pkgs;
    };
  };

  environment.shellAliases = { l = "ls -lah"; };
  environment.shells = [
    "${pkgs.bash}/bin/bash"
    "${pkgs.zsh}/bin/zsh"
  ];

  environment.systemPackages = with pkgs; [
    binutils
    coreutils
    cacert
    psmisc
    lsof
    file
    wget
    gnupg1compat
    git
    gitAndTools.gitAnnex
    curl
    tmux
    screen
    nmap
    htop
    iotop
    zip
    unzip
    zsh
    mc
    telnet
    jwhois
    cryptsetup
    pass
    mr
    vcsh
    rlwrap
    sqlite
    fdupes
    emacs
    elinks
    w3m
    lynx
    storeBackup
    bind
    nix-prefetch-scripts
    markdown
    guile
    openssl
    which
  ];

  users.extraUsers.eike = {
    isNormalUser = true;
    name = "eike";
    group = "users";
    uid = 1000;
    createHome = true;
    home = "/home/eike";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "audio" "messagebus" "systemd-journal" ];
    # openssh.authorizedKeys.keyFiles = [
    #   "./private/id_dsa_eike.pub"
    # ];
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
#    cpu.intel.updateMicrocode = true;  #needs unfree
  };

}
