{ pkgs, emacsPackages }:

emacsPackages.trivialBuild rec {

  pname = "emacs-avro";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "logc";
    repo = "${pname}";
    rev = "1333760eb5324b43f304ecbbd0f3637eaac04469";
    sha256 = "sha256-PoCtklyRrP9HsivhzF3a4IpdlMpDxgPdH63eG0PHveE=";
  };

  packageRequires = with emacsPackages; [ ];
}
