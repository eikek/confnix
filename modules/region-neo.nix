{pkgs, config, ...}:
{
  # Select internationalisation properties.
  console.keyMap = "neo";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
}
