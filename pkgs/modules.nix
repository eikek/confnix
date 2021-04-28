let
  ifds = import ../ifd;
in
[ ./attentive/module.nix
  ./gossa/module.nix
  ./hinclient/module.nix
  ./mpc4s/module.nix
#  ./mpdscribble/module.nix
  ./pickup/module.nix
] ++ (ifds.docspell.modules) ++ (ifds.sharry.modules) ++ (ifds.webact.modules)
