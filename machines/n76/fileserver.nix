{pkgs, config, ...}:
let
   accounts = config.accounts;
in
{

  fileSystems =
  let
    acc = accounts."bluecare/login";
    fileServer = "bluecare-s54";
  in
  {
    "/mnt/fileserver/homes" = {
      device = "//${fileServer}/home";
      fsType = "cifs";
      options = ["user=${acc.username}" "password=${acc.password}" "uid=1000" "user" "vers=2.0"];
    };
    "/mnt/fileserver/transfer" = {
      device = "//${fileServer}/Transfer";
      fsType = "cifs";
      options = ["user=${acc.username}" "password=${acc.password}" "uid=1000" "user" "vers=2.0"];
    };
    "/mnt/fileserver/data" = {
      device = "//${fileServer}/Data";
      fsType = "cifs";
      options = ["user=${acc.username}" "password=${acc.password}" "uid=1000" "user" "vers=2.0"];
    };
  };

}
