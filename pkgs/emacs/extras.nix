{ pkgs, emacsPackages }:
[
  (import ./org-expenses.nix {inherit pkgs emacsPackages;})
  (import ./swagger-mode.nix {inherit pkgs emacsPackages;})
  (import ./emacs-avro.nix {inherit pkgs emacsPackages;})
  (import ./scala-ts-mode.nix {inherit pkgs emacsPackages;})
  pkgs.ds4e
]
