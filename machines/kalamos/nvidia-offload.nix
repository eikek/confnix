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
  nvidia_x11 = config.boot.kernelPackages.nvidiaPackages.stable;
in
{
  environment.systemPackages = [ nvidia-offload nvidia_x11.bin nvidia_x11.settings ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    logFile = null;
    defaultDepth = 24;
    extraConfig = ''
      Section "OutputClass"
         Identifier "NVIDIA"
         MatchDriver "nvidia"
         Driver "nvidia"
         Option "PrimaryGPU" "yes"
      EndSection
    '';
  };

  # hardware.opengl.package = pkgs.lib.mkForce nvidia_x11.out;
  # hardware.opengl.package32 = pkgs.lib.mkForce nvidia_x11.lib32;

  hardware.nvidia.modesetting = {
    enable = true;
  };
  hardware.nvidia.prime = {
    #offload.enable = true;
    sync.enable = true;

    # Bus ID of the AMD GPU. You can find it using lspci, either under 3D or VGA
    amdgpuBusId = "PCI:6:0:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };
}
