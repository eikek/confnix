{ pkgs, emacsPackagesNg }:
[
  (import ./org-expenses.nix {inherit pkgs emacsPackagesNg;})
  (import ./swagger-mode.nix {inherit pkgs emacsPackagesNg;})

]
