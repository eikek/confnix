{ config, pkgs, nixpkgs-unstable, ... }:

let
  unstable = import nixpkgs-unstable {
    system = pkgs.stdenv.system;
    config = { allowUnfree = true; };
  };

  # https://github.com/NixOS/nixpkgs/issues/421775#issuecomment-3033421493
  # must recompile for older nvidia gpu
  ollama-old-cuda = unstable.ollama-cuda.override {
    # nvidia-smi --query-gpu=compute_cap --format=csv
    cudaArches = [ "61" ];
  };

  # ollama-old-cuda = unstable.ollama-cuda.overrideAttrs (final: prev: { preBuild = ''
  #   cmake -B build \
  #     -DCMAKE_SKIP_BUILD_RPATH=ON \
  #     -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  #     -DCMAKE_CUDA_ARCHITECTURES='61' \

  #   cmake --build build -j $NIX_BUILD_CORES
  # '';
  # });
in
{
  services.ollama = {
    enable = true;
    package = ollama-old-cuda;
    host = "0.0.0.0";
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [

  ];

  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
  };

  environment.systemPackages = with pkgs; [
    ollama-old-cuda
    opencode
    ffmpeg
  ];
}
