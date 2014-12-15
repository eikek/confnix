{stdenv, fetchgit, leiningen, jre, makeWrapper, bash, curl}:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "shelter-${version}";

  src = fetchgit {
    url = https://github.com/eikek/shelter;
    rev = "refs/heads/master";
    name = "shelter-${version}-git";
    sha256 = "1510h4mx9qb95i9i7cfhl88mm0y8l0xmvfxlcappk5aw4c209grx";
  };

  buildInputs = [ leiningen jre makeWrapper ];

  buildPhase = ''
    mkdir {.lein,.m2}
    cat >> .lein/profiles.clj <<-"EOF"
      {:user {
         :local-repo "$(pwd)/.m2"
         :repositories
            {"local"
              {:url "file://$(pwd)/.lein"
               :releases {:checksum :ignore}}}}}
    EOF
    HOME=$(pwd) ${leiningen}/bin/lein uberjar
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp target/uberjar/shelter-0.1.0-SNAPSHOT-standalone.jar $out/lib/
    makeWrapper ${jre}/bin/java $out/bin/shelter --add-flags "-jar $out/lib/shelter-0.1.0-SNAPSHOT-standalone.jar"
    cp $src/scripts/shelter_auth $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "Utility for managing virtual user accounts.";
    homepage = https://github.com/eikek/shelter;
    license = licenses.gplv3;
    maintainers = [ maintainers.eikek ];
  };
}
