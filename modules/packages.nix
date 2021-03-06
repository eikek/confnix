{pkgs, config, ...}:
{
  imports = import ../pkgs/modules.nix;

  nixpkgs = {
    config = {
      packageOverrides = import ../pkgs;
    };
  };

  environment.systemPackages = with pkgs; [
    bandwhich
    bat
    binutils
    coreutils
    cryptsetup
    curl
    dmidecode
    dust
    elvish
    exa
    fd
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
    starship
    telnet
    tmux
    unzip
    wget
    which
    bottom
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
