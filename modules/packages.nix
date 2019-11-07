{pkgs, config, ...}:
{
  imports = import ../pkgs/modules.nix;

  nixpkgs = {
    config = {
      packageOverrides = import ../pkgs;
    };
  };

  environment.systemPackages = with pkgs; [
    bat
    binutils
    coreutils
    cryptsetup
    curl
    dmidecode
    elvish
    exa
    file
    gitAndTools.gitFull
    gnupg
    gnused
    htop
    iftop
    iotop
    iptables
    jq
    mc
    openssl
    pciutils
    psmisc
    rsync
    telnet
    tmux
    unzip
    wget
    which
    zip
  ];

  environment.shellAliases = {
    l = "exa -la --git";
    cat = "bat";
  };

  environment.shells = [
    "${pkgs.bash}/bin/bash"
    "${pkgs.zsh}/bin/zsh"
    "${pkgs.elvish}/bin/elvish"
    "${pkgs.fish}/bin/fish"
  ];

}
