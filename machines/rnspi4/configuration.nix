# configuration.nix
#
# nix run nixpkgs#nixos-generators -- -f sd-aarch64 --flake .#rpi4wch --system aarch64-linux -o ./pi.sd
# ^^ old way…
#
# nixos-rebuild build-image --flake .#rpi4wch  --image-variant sd-card
# or: nix build --system aarch64-linux --print-build-logs .#nixosConfigurations.rpi4wch.config.system.build.images.sd-card
# unzstd -d ...
# sudo dd if=~/nixos-sd-image.img of=/dev/mmcblk0 bs=1M status=progress

{ config, pkgs, nixpkgs, dsc, ... }:
let
  sshkeys = import ../../secrets/ssh-keys.nix;
  usermod = import ../../modules/user.nix { username = "eike"; };
in
{
  # note: one of monitor-int or monitor-ext modules is required
  imports = [
    ./hw-pi4.nix
#    ../../modules/emacs.nix
    ../../modules/flakes.nix
    ../../modules/fonts.nix
    ../../modules/ids.nix
    ../../modules/packages.nix
    ../../modules/region-neo.nix
    ../../modules/rns.nix
#    ./vm.nix  # add for testing. ssh -p 11222 root@localhost
    usermod
  ] ++ (import ../../pkgs/modules.nix);

  age.secrets.eike.file = ../../secrets/eike.age;
  users.users.eike.hashedPasswordFile = config.age.secrets.eike.path;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # networking config. important for ssh!
  networking = {
    hostName = "rnspiwch";
    wireless = { enable = true; };
    useDHCP = true;
    firewall.allowedTCPPorts = [ 4242 ];
    firewall.allowedUDPPorts = [ 4242 ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.rns = {
    enable = true;
    rns-pkg = pkgs.unstable.python3Packages.rns;
    lxmd-pkg = pkgs.unstable.python3Packages.lxmf;
  };


  users.users.eike.packages = with pkgs.unstable; [
    python3Packages.pipx python3Packages.nomadnet
  ];

  system.stateVersion = "25.11";

  nixpkgs.hostPlatform = "aarch64-linux";

  # generating the cache takes forever…
  documentation.man.generateCaches = false;
}
