# LibreToy

Bootable USB creator — Like Ventoy, but 100% open source

![logo](./doc/img/LibreToy.png)


## Usage

```bash
sudo nix run .#libretoy-dd $DEVICE
```

This will:
1. build LibreToy (`diskoImage`)
2. copy the `libretoy-bootloader` to `$DEVICE`
3. run `libretoy-repartition` (using free space of `$DEVICE` as defined in disko.nix)
