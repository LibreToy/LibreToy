{ config, pkgs, lib, ... }:

{
  system.stateVersion = config.system.nixos.release;
 
  boot.loader.grub.efiSupport = lib.mkDefault true;
  boot.loader.grub.efiInstallAsRemovable = lib.mkDefault true;
 
  hardware.enableAllHardware = true;
 
  users.users.root.initialPassword = "todo";
}
