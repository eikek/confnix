{ pkgs, emacsPackages }:

let
  triples =
    emacsPackages.trivialBuild rec {
      pname = "triples";
      version = "20250409";
      src = pkgs.fetchFromGitHub {
        owner = "ahyatt";
        repo = pname;
        rev = "3c42e4b3c891cfbc2dd32fe10d7fa82047027bc6";
        sha256 = "sha256-lAd2rAH1721Dgj4XpMF5kzxfnNZfO/RGME8iVk95Qds=";
      };
      packageRequires = with emacsPackages; [
        seq
        kv
      ];
    };
  llm =
    emacsPackages.trivialBuild rec {
      pname = "llm";
      version = "20250409";
      src = pkgs.fetchFromGitHub {
        owner = "ahyatt";
        repo = pname;
        rev = "037b00e81bd470ba1f1cf77ea521cf231ffcb8f7";
        sha256 = "sha256-fal5BulMLdQ6M9F0rEZl2i2ohrLiB+LUMBz+ef5fmfk=";
      };
      packageRequires = with emacsPackages; [
        plz
        plz-event-source
        plz-media-type
      ];
    };
in
emacsPackages.trivialBuild rec {

  pname = "ekg";

  version = "0.7.0";

  src = pkgs.fetchFromGitHub {
    owner = "ahyatt";
    repo = "${pname}";
    rev = "0.7.0";
    sha256 = "sha256-2ZtU57iqpYXDpINvV+0ahM+4eTq4KEROCAYiXjGuJs8=";
  };

  packageRequires = [ triples llm emacsPackages.denote emacsPackages.markdown-mode ];
}
