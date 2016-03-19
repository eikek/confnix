{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
      ./testconf.nix
    ];

  settings = {
  # mac 0800272ACD77
    primaryIp = "192.168.1.74";
  };

  users.extraUsers = {
    demo = {
      isNormalUser = true;
      description = "Demo user account";
      extraGroups = [ "wheel" "audio" "messagebus" "systemd-journal" ];
      password = "demo";
      uid = 1004;
    };
  };

  # slightly modified version from <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
  system.build.skyrosOVA = pkgs.runCommand "virtualbox-ova"
      { buildInputs = [ pkgs.linuxPackages.virtualbox ];
        vmName = "Skyros ${config.system.nixosVersion} (${pkgs.stdenv.system})";
        fileName = "skyros-${config.system.nixosVersion}-${pkgs.stdenv.system}.ova";
      }
      ''
        echo "creating VirtualBox VM..."
        export HOME=$PWD
        VBoxManage createvm --name "$vmName" --register \
          --ostype ${if pkgs.stdenv.system == "x86_64-linux" then "Linux26_64" else "Linux26"}
        VBoxManage modifyvm "$vmName" \
          --memory 2500 --acpi on --vram 10 \
          --nictype1 virtio --nic1 bridged \
          --audiocontroller ac97 --audio alsa \
          --rtcuseutc on \
          --usb on --mouse usbtablet
        VBoxManage storagectl "$vmName" --name SATA --add sata --portcount 4 --bootable on --hostiocache on
        VBoxManage storageattach "$vmName" --storagectl SATA --port 0 --device 0 --type hdd \
          --medium ${config.system.build.virtualBoxImage}/disk.vdi

        echo "exporting VirtualBox VM..."
        mkdir -p $out
        VBoxManage export "$vmName" --output "$out/$fileName"
      '';
}
