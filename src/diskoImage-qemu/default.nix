{ self, cfg, pkgs }:

let
  diskoImage = self.packages.${cfg.nixpkgs.system}."diskoImage";
  ram = "2G";
in
with pkgs; writeShellApplication {
  name = "diskoImage-qemu";
  runtimeInputs = [ qemu diskoImage ];
  text = ''
    IMAGE="${diskoImage}/${cfg.networking.hostName}.raw"

    qemu-system-x86_64 \
      -enable-kvm \
      -m ${ram} \
      -drive "if=virtio,format=raw,snapshot=on,file=$IMAGE"
  '';
}
