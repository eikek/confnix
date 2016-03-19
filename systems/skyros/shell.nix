with import <nixpkgs> {};
let
  nixos = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-15.09.tar.gz";
  makeova = writeScript "makeova.sh" ''
    #!${bash}/bin/bash -e
    NIXOS_CONFIG="$(pwd)/testvm.nix";
    NIX_PATH="nixpkgs=${nixos}:nixos-config=$(pwd)/testvm.nix";
    nix-build '<nixpkgs/nixos>' -A config.system.build.skyrosOVA $@
  '';
  systembuild = writeScript "systembuild" ''
    #!${bash}/bin/bash -e
    NIXOS_CONFIG="$(pwd)/configuration.nix";
    NIX_PATH="nixpkgs=${nixos}:nixos-config=$(pwd)/configuration.nix";
    nixos-rebuild $@
  '';
  testbuild = writeScript "testbuild" ''
    #!${bash}/bin/bash -e
    NIXOS_CONFIG="$(pwd)/testconf.nix";
    NIX_PATH="nixpkgs=${nixos}:nixos-config=$(pwd)/testconf.nix";
    nixos-rebuild $@
  '';
  runvm = writeScript "runvm.sh" ''
    #!${bash}/bin/bash -e
    # run `nixos-rebuild build-vm` and then this script. this is only
    # to change some params to the qemu command.
    # networking works only, if the host system is setup correctly, see
    # https://nixos.org/wiki/QEMU_guest_with_networking_and_virtfs
    # create a /etc/hosts entry mapping {git.|webmail|…}testvm.com to 10.0.2.15
    export TMPDIR=/tmp
    rm -f run.sh
    cp ./result/bin/run-skyrostest-vm run.sh
    sed -i 's|-net nic.*$|-net nic,model=virtio -net vde \\|g' run.sh
    sed -i 's|-m 384|-m 3840|g' run.sh
    ./run.sh
  '';
in
runCommand "zsh" rec {
  buildInputs = [ nix ];
  shellHook = ''
     alias makeova='${makeova}'
     alias runvm='${runvm}'
     alias rebuild='${systembuild}'
     alias testrebuild='${testbuild}'
     SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';
} ""
