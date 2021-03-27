{pkgs, config, ...}:
{

  services.udev.extraRules = ''
   # Rule for all ZSA keyboards
   SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="users"
   # Rule for the Moonlander
   SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="users"
  '';
}
