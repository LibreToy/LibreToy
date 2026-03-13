{ pkgs, ... }:

let
  InfOS = builtins.fromJSON (builtins.readFile ../../InfOS.json);
in
with pkgs; writeShellApplication {
  name = "install-bootloader";
  runtimeInputs = [
    coreutils  ## dd
    busybox    ## partprobe
    gptfdisk   ## sgdisk gdisk
    exfat      ## mkfs.exfat
  ];
  text = ''
    if [ $# -lt 1 ]; then
      echo "Usage: $0 <DEVICE>"
      exit 1
    fi
    DEVICE=$1

    nix build .#disko-image
    IMAGE="result/${InfOS.hostName}.raw"


    function copy() {
      ## Copy all partitions up to $PARTNAME_LAST

      PARTNAME_LAST="disk-${InfOS.hostName}-ESP"  ## The last partition to be copied
      SECTOR_SIZE=$(sgdisk -p $IMAGE | awk '/Sector size \(logical\)/ {print $4}')
      SECTORS=$(sgdisk -p $IMAGE | awk -v PARTNAME="$PARTNAME_LAST" '$7 ~ PARTNAME {print $3}')

      BYTES=$((SECTOR_SIZE * SECTORS))
      BS=$((8 * 1024 * 1024))  ## 8MiB should be lange enough for good performance
      COUNT=$(( (BYTES + BS-1) / BS ))  ## Round up

      dd if="$IMAGE" of="$DEVICE" bs="$BS" count="$COUNT" status=progress

      echo -e "v\nw\ny\ny" | gdisk "$DEVICE"  ## Fix backup header
      partprobe "$DEVICE"
      sgdisk -p "$DEVICE"  ## For debugging
    }
    copy


    function resize() {
      ## Resize last partition

      PARTITION_LAST=$(sgdisk -p "$DEVICE" | tail -n 1 | awk '{print $1}')
      PARTITION_NAME=$(sgdisk -p "$DEVICE" | tail -n 1 | awk '{print $7}')
      START_SECTOR=$(sgdisk -p "$DEVICE" | tail -n 1 | awk '{print $2}')
      sgdisk --delete="$PARTITION_LAST" "$DEVICE"
      sgdisk --new="$PARTITION_LAST:$START_SECTOR:0" "$DEVICE"
      sgdisk --change-name="$PARTITION_LAST:$PARTITION_NAME" "$DEVICE"
    }
    resize


    function format() {
      ## Recreate EXFAT-partition

      PARTNAME_EXFAT="disk-${InfOS.hostName}-EXFAT"
      PARTNR=$(sgdisk -p $IMAGE | awk -v PARTNAME="$PARTNAME_EXFAT" '$7 ~ PARTNAME {print $1}')

      if [ -b "$DEVICE-part$PARTNR" ]; then
        PART_EXFAT=$DEVICE-part$PARTNR
      elif [ -b "$DEVICE$PARTNR" ]; then
        PART_EXFAT=$DEVICE$PARTNR
      else
        echo "Device for partition $PARTNR of $DEVICE not found!"
        exit 2
      fi

      mkfs.exfat -n "EXFAT" "$PART_EXFAT"
      sgdisk -p "$DEVICE"  ## For debugging


      ## Create /iso directory

      TEMP_DIR=$(mktemp -d /tmp/mnt-exfat.XXXXXX)
      mount "$PART_EXFAT" "$TEMP_DIR"
      mkdir "$TEMP_DIR/iso"
      umount "$PART_EXFAT"
      rmdir "$TEMP_DIR"
    }
    format
  '';
}
