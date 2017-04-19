{config, pkgs, lib, ... }:

{
  config = {
    ids.uids = {
      exim = 399;
      sitebag = 398;
      gitblit = 397;
      shelter = 396;
      publet = 395;
      fetchmail = 394;
      gitbucket = 393;
      gitea = 392;
      fileshelter = 391;
    };

    ids.gids = {
      exim = 399;
      sitebag = 398;
      gitblit = 397;
      shelter = 396;
      publet = 395;
      fetchmail = 394;
      gitbucket = 393;
      gitea = 392;
      fileshelter = 391;
    };
  };
}
