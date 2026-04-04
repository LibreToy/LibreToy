{ self, cfg, pkgs }:

pkgs.stdenv.mkDerivation {
  name = "libretoy-bootloader";
  unpackPhase = "true";
  buildPhase = ''
    mkdir -p $out/nix-support
    ${self.packages.${cfg.nixpkgs.system}.libretoy-dd}/bin/libretoy-dd $out/libretoy.img;
    echo "file img $out/libretoy.img" > $out/nix-support/hydra-build-products
  '';
}
