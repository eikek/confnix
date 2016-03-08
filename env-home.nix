{ config, pkgs, ... }:

{
  # needed for the `user` option below
  security.setuidPrograms = [ "mount.cifs" ];

  fileSystems = builtins.listToAttrs (map (mp:
    { name = "/mnt/nas/" + mp;
      value = {
        device = "//nas/" + mp;
        fsType = "cifs";
        options = ["noauto" "user" "username=eike" "password=eike" "uid=1000" "gid=100" ];
        noCheck = true;
      };
    }) ["backups" "dokumente" "downloads" "home" "music" "photo" "safe" "video"]);

}
