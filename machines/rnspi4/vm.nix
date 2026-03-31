{
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  virtualisation.forwardPorts = [
    {
      from = "host";
      host.port = 11222;
      guest.port = 22;
    }
  ];

  users.users.root = {
    password = "root";
  };
  # i18n = {
  #   defaultLocale = "en_US.UTF-8";
  # };

  virtualisation.graphics = false;

  documentation.enable = false;
}
