let
  ifds = import ../ifd;
in
[
  ./attentive/module.nix
  ./gossa/module.nix
  ./mpc4s/module.nix
  ./pickup/module.nix
  ./solr/module.nix
] ++ (ifds.webact.modules)
