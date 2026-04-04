{ self, cfg, pkgs }:

let
  iso = self.packages.${cfg.nixpkgs.system}."iso";
  ram = "2G";
in
with pkgs; writeShellApplication {
  name = "iso-qemu";
  runtimeInputs = [ qemu iso ];
  text = ''
    qemu-system-x86_64 \
      -enable-kvm \
      -m ${ram} \
      --cdrom ${iso}/iso/*.iso
  '';
}
