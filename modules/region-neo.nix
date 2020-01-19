{pkgs, config, ...}:
{
  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "neo";
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
}
