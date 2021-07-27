{pkgs, config, ... }:
let
  accounts = config.accounts;
  dsInt = accounts."home/nassy/docspell".integration;
  dsSite = accounts."home/nassy/docspell".site;
in
{
  services.dsc-watch = {
    enable = true;
    integration-endpoint = {
      enabled = true;
      header = "Docspell-Integration:${dsInt}";
    };
    verbose = false;
    deleteFiles = true;
    watchDirs = ["/home/docspell"];
    docspell-url = dsSite;
  };

  system.activationScripts = {
    "dsc-watch" = ''
      mkdir -p /home/docspell
    '';
  };
}
