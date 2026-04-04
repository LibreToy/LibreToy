{ self, cfg, pkgs, ... }:

let
  diskoImage = self.packages.${cfg.nixpkgs.system}."diskoImage";
in
with pkgs; writeShellApplication {
  name = "libretoy-dd";
  runtimeInputs = [
    coreutils  ## dd
    busybox    ## partprobe
    gptfdisk   ## sgdisk gdisk

    self.packages.${cfg.nixpkgs.system}.libretoy-repartition
  ];
  text = ''
    if [ $# -lt 1 ]; then
      echo "Usage: $0 <DEVICE>"
      exit 1
    fi
    DEVICE=$1

    IMAGE="${diskoImage}/${cfg.networking.hostName}.raw"


    function copy() {
      ## Copy all partitions up to $PARTNAME_LAST

      PARTNAME_LAST="disk-${cfg.networking.hostName}-ESP"  ## The last partition to be copied
      PARTNUMBER_LAST=$(sgdisk -p $IMAGE | awk -v PARTNAME="$PARTNAME_LAST" '$7 ~ PARTNAME {print $1}')

      SECTOR_SIZE=$(sgdisk -p $IMAGE | awk '/Sector size \(logical\)/ {print $4}')
      SECTORS=$(sgdisk -p $IMAGE | awk -v PARTNAME="$PARTNAME_LAST" '$7 ~ PARTNAME {print $3}')

      BYTES=$((SECTOR_SIZE * SECTORS))
      BS=$((8 * 1024 * 1024))  ## 8MiB should be large enough for good performance
      COUNT=$(( (BYTES + BS-1) / BS ))  ## Round up

      dd if="$IMAGE" of="$DEVICE" bs="$BS" count="$COUNT" status=progress

      if [[ "$DEVICE" == *".img" ]]; then
        echo
        echo "\$DEVICE is an .img file."
        echo "GPT-Backups headers are not fixed, since file is too small."
      else
        echo "Fix backup header"
        echo -e "v\nw\ny\ny" | gdisk "$DEVICE"
        partprobe "$DEVICE"
        sgdisk -p "$DEVICE"  ## For debugging

        echo "Repartition remaining partitions"
        libretoy-repartition "$DEVICE" "$PARTNUMBER_LAST"
      fi
    }
    copy
  '';
}
