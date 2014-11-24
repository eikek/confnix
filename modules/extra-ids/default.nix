{config, pkgs, lib, ... }:

{
  config = {
    ids.uids = {
      exim = 399;
      sitebag = 398;
      gitblit = 397;
    };

    ids.gids = {
      exim = 399;
      sitebag = 398;
      gitblit = 397;
    };
  };
}
