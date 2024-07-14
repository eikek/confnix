{ pkgs, config, dsc, agenix, ds4e, webact, ... }: {
  imports =
    # legacy
    import ../pkgs/modules.nix ++
    # flakes
    [
      dsc.nixosModules.default
      agenix.nixosModules.default
      webact.nixosModules.default
    ];

  environment.systemPackages = with pkgs; [
    bandwhich
    bat
    binutils
    coreutils
    cryptsetup
    curl
    dmidecode
    elvish
    eza
    fd
    file
    gitAndTools.gitFull
    gnupg
    gnused
    htop
    btop
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
    inetutils
    tmux
    unzip
    wget
    which
    bottom
    zip
  ];

  environment.shellAliases = {
    l = "eza -la --git";
    cat = "bat";
  };

  environment.shells = [
    "${pkgs.bash}/bin/bash"
    "${pkgs.zsh}/bin/zsh"
    "${pkgs.elvish}/bin/elvish"
    "${pkgs.fish}/bin/fish"
  ];

  security.pam.sshAgentAuth.enable = true;

  programs = {
    direnv.enable = true;
    fish.enable = true;
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment = { homeBinInPath = true; };

  users.users.root =
    let sshkeys = import ../secrets/ssh-keys.nix;
    in { openssh.authorizedKeys.keys = [ sshkeys.eike ]; };
}
