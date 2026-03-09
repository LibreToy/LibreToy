{ pkgs, ... }:

let
  InfOS = builtins.fromJSON (builtins.readFile ./InfOS.json);
in
{
  disko.imageBuilder.extraDependencies = with pkgs; [ exfat ];
  disko.devices = {
    disk = {
      ${InfOS.hostName} = {
        #device = "${InfOS.device}";
        type = "disk";
        imageSize = "7G";
        content = {
          type = "gpt";
          partitions = {

            BBP = {  # BIOS boot partition
              priority = 1;
              type = "EF02";  # for grub MBR
              size = "1M";
            };
            ESP = {  # EFI system partition
              priority = 2;
              type = "EF00";
              size = "100M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ] ++ [ "nofail" ];
              };
            };

            NIXOS = {
              priority = 10;
              size = "3G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "noatime" "nodiratime" "discard" "barrier=0" ];
              };
            };
            HOME = {
              priority = 11;
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
                mountOptions = [ "noatime" "nodiratime" "discard" "barrier=0" ];
              };
            };

            EXFAT = {  # ISOs, Win-Share
              priority = 100;
              size = "100%";
              content = {
                type = "filesystem";
                format = "exfat";
                mountpoint = "/mnt/exfat";
                mountOptions = [ "umask=0077" ] ++ [ "nofail" ];
              };
            };

          };
        };
      };
    };
  };
}
