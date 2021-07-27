let
  ifds = import ../ifd;
  dscsrc = builtins.fetchTarball "https://github.com/docspell/dsc/archive/7e173a87180ceaa4093e81b5988bbeba6923a439.tar.gz";
in
[ ./attentive/module.nix
  ./gossa/module.nix
  ./hinclient/module.nix
  ./mpc4s/module.nix
#  ./mpdscribble/module.nix
  ./pickup/module.nix
  "${dscsrc}/nix/module.nix"
] ++ (ifds.docspell.modules) ++ (ifds.sharry.modules) ++ (ifds.webact.modules)
