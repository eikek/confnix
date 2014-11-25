# confnix -- my nixos config files

These are the configuration file for some of my
[NixOs](http://nixos.org) installations.

## Setup

    cd /etc/nixos
    git clone .../confnix
    ln -s confnix/systems/some-conf.nix configuration.nix
    nixos-rebuild switch




## Credits

Aside from the nix/nixpgs manuals, I looked at some other
configuration setups and stole from them:

- https://github.com/aszlig/vuizvui
- https://github.com/chaoflow/nixos-configurations
