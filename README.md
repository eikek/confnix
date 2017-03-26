# confnix -- my nixos config files

These are the configuration file for some of my
[NixOs](http://nixos.org) installations.

## Setup

    cd /etc/nixos
    git clone https://github.com/eikek/confnix
    ln -s confnix/systems/some-conf.nix configuration.nix
    nixos-rebuild switch


## Try out packages

Try out some packages defined [here](pkgs/) using `nix-build`:

    nix-build -A <package>

The `default.nix` file returns the original packages set of your
current nixos plus all packages from this repo. The packages will use
dependencies from current nixos, so it might not work out depending on
the version of nixpkgs.

## Credits

Aside from the nix/nixpgs manuals, I got inspired by other
configuration setups:

- https://github.com/aszlig/vuizvui
- https://github.com/chaoflow/nixos-configurations
