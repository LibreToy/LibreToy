{ lib, ... }:

{
  boot.loader.grub = {
    enable = true;

    efiSupport = lib.mkDefault true;
    efiInstallAsRemovable = lib.mkDefault true;

    configurationLimit = lib.mkDefault 10;

    extraEntriesBeforeNixOS = true;
    default = "saved";
  };
}
