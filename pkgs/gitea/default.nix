{ stdenv, buildGoPackage, fetchFromGitHub, makeWrapper
, git, coreutils, bash, gzip, openssh
, sqliteSupport ? true
}:

buildGoPackage rec {
  name = "gitea-${version}";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "go-gitea";
    repo = "gitea";
    rev = "v${version}";
    sha256 = "1askcfl300m6v15rc9hz2k8l8smjlfzczhjs26g0r4apr09yc9im";
  };

  patchPhase = ''
    substituteInPlace models/repo.go \
      --replace '#!/usr/bin/env' '#!${coreutils}/bin/env'
  '';

  buildInputs = [ makeWrapper ];

  buildFlags = stdenv.lib.optionalString sqliteSupport "-tags sqlite";

  outputs = [ "bin" "out" "data" ];

  postInstall = ''
    mkdir $data
    cp -R $src/{public,templates,options} $data

    wrapProgram $bin/bin/gitea \
      --prefix PATH : ${stdenv.lib.makeBinPath [ bash git gzip openssh ]} \
      --run 'export GITEA_WORK_DIR=''${GITEA_WORK_DIR:-$PWD}' \
      --run 'mkdir -p "$GITEA_WORK_DIR" && cd "$GITTEA_WORK_DIR"' \
      --run "ln -fs $data/{public,templates} ."
  '';

  goPackagePath = "code.gitea.io/gitea";
  goDeps = ./deps.nix;

  meta = {
    description = "A painless self-hosted Git service";
    homepage = "http://gitea.io/";
    license = stdenv.lib.licenses.mit;
  };
}
