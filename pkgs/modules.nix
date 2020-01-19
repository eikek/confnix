let
  ifds = import ../ifd;
in
[ ./attentive/module.nix
  ./gossa/module.nix
  ./hinclient/module.nix
  ./mpc4s/module.nix
  ./mpdscribble/module.nix
  ./pickup/module.nix
  ./sharry/module.nix
  ./webact/module.nix
] ++ (ifds.docspell.modules)
