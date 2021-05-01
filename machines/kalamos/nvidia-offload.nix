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
  environment.systemPackages = [
    config.boot.kernelPackages.nvidia_x11.bin
    config.boot.kernelPackages.nvidia_x11.settings
  ];

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
    ];
    extraModulePackages =
      [ config.boot.kernelPackages.nvidia_x11
        #      config.boot.kernelPackages.amdgpu-pro #doesn't build
      ];
    blacklistedKernelModules =
      [ "nouveau"
        "rivafb"
        "nvidiafb"
        "rivatv"
        "nv"
        "uvcvideo"
      ];
  };

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages =
      [config.boot.kernelPackages.nvidia_x11.out
      ];
    extraPackages32 =
      [ config.boot.kernelPackages.nvidia_x11.lib32
      ];
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    useGlamor = true;
    logFile = null;
  };

}
