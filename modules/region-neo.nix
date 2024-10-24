{ pkgs, config, ... }:
{
  # Select internationalisation properties.
  console.keyMap = "neo";
  i18n = {
    defaultLocale = "en_GB.UTF-8";

    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "de_CH.UTF-8/UTF-8"
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
}
