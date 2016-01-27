{ stdenv, fetchFromGitHub, autoreconfHook, pam, getopt }:

stdenv.mkDerivation rec {
  version = "1.1.7";
  name = "pam_script-${version}";

  src = fetchFromGitHub {
    owner = "jeroennijhof";
    repo = "pam_script";
    rev = "${version}";
    sha256 = "0rv5wivjp27kdy5nwg1pagvj8c9aryva4r10d1yy2r6q5w74fmd3";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ pam getopt ];

  meta = with stdenv.lib; {
    description = "Support to authenticate against external scripts for PAM-enabled appliations";
    homepage = https://github.com/jeroennijhof/pam_script;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
