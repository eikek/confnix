let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/c6a9a17f896a1680a579ea83c4af06c5a7a79e4d.tar.gz";
    sha256 = "sha256:014sabvw0vdyrjbmanpw22f3wwrm8h7k8fh1hcvdn3iln6s71b2x";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

  ds4esrc = builtins.fetchTarball {
    url = "https://github.com/docspell/ds4e/archive/master.tar.gz";
    sha256 = "sha256:13dydc0l3nr44ig37jvzn3aww3zm53809aks5brh92ywpd0ahfky";
  };
  ds4e = import "${ds4esrc}/nix/ds4e.nix";

  sharrysrc = builtins.fetchTarball {
    url = "https://github.com/eikek/sharry/archive/f0836051b4d656aa185dcb37d7daf842b6425ee8.tar.gz";
    sha256 = "1gm8nyvib9p22s23b9fh2ni15zh2j2xi62p8as2v936pjdhw5ks9";
  };
  sharry = import "${sharrysrc}/nix/release.nix";

  webactsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/webact/archive/05bccd47e8b31bbc3ce2fcaa0f97481a1508a7a8.tar.gz";
    sha256 = "0lb920b0bdbg5r4489cc1y9lf88g05zbb8imcswsiml8ih6h38iw";
  };
  webact = import "${webactsrc}/nix/release.nix";
in {
  inherit docspell sharry webact ds4e;
}
