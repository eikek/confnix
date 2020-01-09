{pkgs, config, ...}:
let
   accounts = config.accounts;
in
{

  fileSystems =
  let
    acc = accounts."bluecare/login";
    fileServer = "bluecare-s54";
    automount_opts = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" ];
    options = ["user=${acc.username}" "password=${acc.password}" "uid=1000" "user" "vers=2.0"] ++ automount_opts;
  in
  {
    "/mnt/fileserver/homes" = {
      device = "//${fileServer}/home";
      fsType = "cifs";
      inherit options;
    };
    "/mnt/fileserver/transfer" = {
      device = "//${fileServer}/Transfer";
      fsType = "cifs";
      inherit options;
    };
    "/mnt/fileserver/data" = {
      device = "//${fileServer}/Data";
      fsType = "cifs";
      inherit options;
    };
  };

}
