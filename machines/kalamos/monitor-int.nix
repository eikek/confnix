## https://nixos.wiki/wiki/Nvidia#offload_mode
#
# # nix-shell -p lshw --run "lshw -c display"|grep "bus info"
#       bus info: pci@0000:01:00.0
#       bus info: pci@0000:06:00.0
#
{ config, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export DRI_PRIME=1
    exec -a "$0" "$@"
  '';

in
{

  environment.systemPackages = [ nvidia-offload ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    logFile = null;
    defaultDepth = 24;
  };

  hardware.nvidia.prime = {
    offload.enable = true;
    sync.enable = false;

    # Bus ID of the AMD GPU. You can find it using lspci, either under 3D or VGA
    amdgpuBusId = "PCI:6:0:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };
}
