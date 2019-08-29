{pkgs, config, ...}:
{
  imports = import ../pkgs/modules.nix;

  nixpkgs = {
    config = {
      packageOverrides = import ../pkgs;
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
    rsync
    telnet
    htop
    iftop
    iotop
    mc
    zip
    unzip
    exa
    bat
    elvish
    coreutils
    gnused
    dmidecode
    pciutils
    tmux
    gnupg
    cryptsetup
    psmisc
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
