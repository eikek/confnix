users: { pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.wineWowPackages.stable
  ];
}
