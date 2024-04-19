{
  home =
    { config, pkgs, ... }:
    {
      hardware.printers = {
        ensurePrinters = [
          {
            name = "LexmarkMC2425";
            location = "Home";
            description = "Laserprinter";
            deviceUri = "socket://lexi.home";
            model = "lexmark/mc2425.ppd";
          }
        ];
        ensureDefaultPrinter = "LexmarkMC2425";
      };
      services.printing = {
        enable = true;
        drivers = [ pkgs.mc2425ppd ];
      };
    };

  sdsc = { config, pkgs, ... }:
    {
      hardware.printers = {
        ensurePrinters = [
          {
            name = "ETHZCard";
            #deviceUri = "ipps://pia01.d.ethz.ch:9164/printers/card-ethz";
            deviceUri = "smb://pia01.d.ethz.ch/card-ethz";
            location = "ETH Cloud";
            description = "Card-ethz IPP";
            model = "ricoh/mp_c3003ps.ppd";
          }
        ];
      };
      services.printing = {
        enable = true;
        drivers = [ pkgs.mc3ppd ];
      };
    };
}
