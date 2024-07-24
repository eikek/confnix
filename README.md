# confnix -- my nixos config files

These are the configuration file for some of my
[NixOs](http://nixos.org) installations.

## Setup

    cd /etc/nixos
    git clone https://github.com/eikek/confnix
    ln -s confnix/flake.nix .
    nixos-rebuild switch


## Try out packages

Try out some packages defined [here](pkgs/) using `nix build` or `nix
run`:

    nix build .#chee


## Build a machines configuration

To test build a machine configuration, the machine can be given to
`nixos-rebuild` command:

``` bash
nixos-rebuild build --flake .#kalamos
```

To create vm of some machine's config:
```
nixos-rebuild build-vm --flake .#kalamos
```

To deploy at some machine:
```
nixos-rebuild switch --flake .#icaria \
  --target-host root@192.168.1.228 --build-host localhost --verbose
```
