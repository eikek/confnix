{config, pkgs, lib, ... }:

{
  config = {
    ids.uids = {
      exim = 399;
      sitebag = 398;
      gitblit = 397;
      shelter = 396;
      publet = 395;
    };

    ids.gids = {
      exim = 399;
      sitebag = 398;
      gitblit = 397;
      shelter = 396;
      publet = 395;
    };
  };
}
