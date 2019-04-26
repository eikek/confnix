{ config, pkgs, ... }:

{
  # needed for the `user` option below
  security.wrappers."mount.cifs".source = "${pkgs.cifs-utils}/bin/mount.cifs";

  fileSystems = builtins.listToAttrs (map (mp:
    { name = "/mnt/nas/" + mp;
      value = {
        device = "//files.home/" + mp;
        fsType = "cifs";
        options = ["noauto" "user" "username=eike" "password=eike" "uid=1000" "gid=100" "vers=2.0" ];
        noCheck = true;
      };
    }) ["data" "eike"]);

}
