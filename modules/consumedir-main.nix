{pkgs, config, ... }:
let
  accounts = config.accounts;
  dsInt = accounts."home/nassy/docspell".integration;
  dsSite = accounts."home/nassy/docspell".site;
in
{
  services.docspell-consumedir = {
    enable = true;
    runAs = "root";
    integration-endpoint = {
      enabled = true;
      header = "Docspell-Integration:${dsInt}";
    };
    verbose = true;
    distinct = true;
    deleteFiles = true;
    watchDirs = ["/home/docspell"];
    urls = ["${dsSite}/api/v1/open/integration/item"];
  };

  system.activationScripts = {
    "docspell-consumedir" = ''
      mkdir -p /home/docspell
    '';
  };
}
