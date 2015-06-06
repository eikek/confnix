{stdenv, fetchgit, leiningen, jre, makeWrapper, bash, curl, coreutils, gnugrep}:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "shelter-${version}";

   src = fetchgit {
     url = https://github.com/eikek/shelter;
     rev = "e52c9a51a8f0f6d935f9e8d968fb9991d1ab8144";
     name = "shelter-${version}-git";
     sha256 = "0zqv4kwpr33yr6d9i4v2r8ky6x3801jl6k50zfx7sbk7rj2fjjy2";
   };
#  src = /home/eike/workspace/projects/shelter;

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

  patchPhase = ''
    sed -i 's,head,${coreutils}/bin/head,g' scripts/shelter_auth
    sed -i 's,grep,${gnugrep}/bin/grep,g' scripts/shelter_auth
    sed -i 's,curl,${curl}/bin/curl,g' scripts/shelter_auth
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp target/uberjar/shelter-0.1.0-SNAPSHOT-standalone.jar $out/lib/
    makeWrapper ${jre}/bin/java $out/bin/shelter --add-flags "-jar $out/lib/shelter-0.1.0-SNAPSHOT-standalone.jar"
    cp scripts/shelter_auth $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "Utility for managing virtual user accounts.";
    homepage = https://github.com/eikek/shelter;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
