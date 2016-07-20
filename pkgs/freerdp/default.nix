{ lib, fetchFromGitHub, freerdpUnstable }:

lib.overrideDerivation freerdpUnstable (attrs: {
  name = "freerdp-1.2.0-9ef863bf";

  src = fetchFromGitHub {
    owner = "FreeRDP";
    repo = "FreeRDP";
    rev = "9ef863bf21755febccc6d385a07be87175874228";
    sha256 = "1kvzgd06kj471vfjvp7dbpqhrrzhmbcsmb5qp87wx6qwsbrn6kd4";
  };
})
