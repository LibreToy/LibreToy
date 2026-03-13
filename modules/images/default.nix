{ pkgs, ... }:

let
  available_images = {
    "iso/nixos-25.11-minimal-x86_64-linux.iso" = builtins.fetchurl {
      url = "https://releases.nixos.org/nixos/25.11/nixos-25.11.4270.77ef7a29d276/nixos-minimal-25.11.4270.77ef7a29d276-x86_64-linux.iso";
      sha256 = "1fsqn7mh98qrfml470bhc8na0mhw9jwcg4sfcqi6fcy8d81wfmy5";  ## nix-prefetch-url --type sha256 $URL
    };
  };

  images = {};  # available_images;  ## TODO
in
{
  ## TODO: allow to copy the images to another destination than "/boot"
  boot.loader.grub = {
    extraFiles = images;
  };
}
