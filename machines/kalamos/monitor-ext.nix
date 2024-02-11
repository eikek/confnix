## https://nixos.wiki/wiki/Nvidia#offload_mode
#
# # nix-shell -p lshw --run "lshw -c display"|grep "bus info"
#       bus info: pci@0000:01:00.0
#       bus info: pci@0000:06:00.0
#
{ config, pkgs, ... }:
{

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    logFile = null;
  };

  hardware.nvidia.modesetting = {
    enable = true;
  };

  hardware.nvidia.prime = {
    offload.enable = false;
    sync.enable = true;

    # Bus ID of the AMD GPU. You can find it using lspci, either under 3D or VGA
    amdgpuBusId = "PCI:6:0:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };
}
