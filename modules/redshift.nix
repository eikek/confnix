{pkgs, config, ...}:
{
  services.redshift = {
    enable = true;
    brightness.night = "0.8";
    temperature.night = 3500;
  };
  location = {
    latitude = 47.5;
    longitude = 8.75;
  };
}
