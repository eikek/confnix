# confnix -- my nixos config files

These are the configuration file for some of my
[NixOs](http://nixos.org) installations.

## Setup

    cd /etc/nixos
    git clone https://github.com/eikek/confnix
    ln -s confnix/flake.nix .
    nixos-rebuild switch


## Try out packages

Try out some packages defined [here](pkgs/) using `nix-build`:

    nix-build -A <package>

The `default.nix` file returns the original packages set of your
current nixos plus all packages from this repo. The packages will use
dependencies from current nixos, so it might not work out depending on
the version of nixpkgs.


## Build a machines configuration

To test build a machine configuration, the `configuration.nix` can be
given to `nixos-rebuild` command:

``` bash
NIXOS_CONFIG=$(pwd)/machines/kythira/configuration.nix nixos-rebuild build
```
