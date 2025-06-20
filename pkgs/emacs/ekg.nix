{ pkgs, emacsPackages }:

let
  triples =
    emacsPackages.trivialBuild rec {
      pname = "triples";
      version = "20250620";
      src = pkgs.fetchFromGitHub {
        owner = "ahyatt";
        repo = pname;
        rev = "5e17182a5374a1656761bb26832fd21c6f168685";
        sha256 = "sha256-E0SFEabHYA0PmamClLh6XmxlzhpBd41+Mkdo+04lcYs=";
      };
      packageRequires = with emacsPackages; [
        seq
        kv
      ];
    };
  llm =
    emacsPackages.trivialBuild rec {
      pname = "llm";
      version = "20250620";
      src = pkgs.fetchFromGitHub {
        owner = "ahyatt";
        repo = pname;
        rev = "7f11ee2d61e7ff24b3895851854a2b3856ac83f2";
        sha256 = "sha256-K5SjKs6nv7wVY8jLmbw1rN3YX3d/xgtTEplTm4PzrnY=";
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

  version = "0.7.1";

  src = pkgs.fetchFromGitHub {
    owner = "ahyatt";
    repo = "${pname}";
    rev = "0.7.1";
    sha256 = "sha256-06Nr/v39IhMMLry/5wJUNhpCYJQU+g0zTnLa5qVzw6Y=";
  };

  packageRequires = [ triples llm emacsPackages.denote emacsPackages.markdown-mode ];
}
