{ config, pkgs, ... }:
let
  acc = config.accounts."bluecare/login";
in
{

  hardware.printers =
    let
      credentials = "${acc.domain}\\${acc.username}:${acc.password}";
      printserver = "bluecare-s20";
      location = "BlueCare";
      description = "Kyocera TASKalfa 300ci";
      model = "Kyocera/Kyocera_TASKalfa_300ci.ppd";
    in
      {
        ensurePrinters = [
          {
            name = "FollowMe";
            location = location;
            description = description;
            deviceUri = "smb://${credentials}@${printserver}/FollowMe";
            model = model;
          }
          {
            name = "FollowMe_Color";
            location = location;
            description = "${description} Color";
            deviceUri = "smb://${credentials}@${printserver}/FollowMe%20Color";
            model = model;
          }
        ];
        ensureDefaultPrinter = "FollowMe";
      };

  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-kyodialog3 ];
  };

}
