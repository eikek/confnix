{ pkgs, config, dsc, agenix, ds4e, ... }: {
  imports =
    # legacy
    import ../pkgs/modules.nix ++
    # flakes
    [ dsc.nixosModules.default agenix.nixosModules.default ];

  nixpkgs = { config = { packageOverrides = import ../pkgs; }; };

  nixpkgs.overlays =
    let system = pkgs.stdenv.hostPlatform.system;
    in [
      #dsc.overlays.default <- this tries to rebuild dsc with default nixpkgs (that is 23.11) and an outdated cargo
      (final: prev: { dsc = dsc.packages.${system}.default; })
      (final: prev: { ds4e = ds4e.packages.${system}.default; })
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

  security.pam.enableSSHAgentAuth = true;

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
