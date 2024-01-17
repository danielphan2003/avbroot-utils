#! /usr/bin/env bash
export PRJ_ROOT="$(pwd)"

# Extract kernel zip
unzip -u ./kernel.zip Image.lz4
mv Image.lz4 ./kernel/

unzip -u ./kernel.zip dtbo.img
mv dtbo.img ./kernel/

if [ ! -d ./extracted ]; then
  # Extract the original OTA to get boot.img and dtbo.img
  avbroot ota extract -i original_ota.zip -d extracted --all
fi

# Unpack boot.img
mkdir -p "$PRJ_ROOT"/extracted/boot
cd "$PRJ_ROOT"/extracted/boot
avbroot avb unpack -i ../boot.img
avbroot boot unpack -i raw.img

# Replace the kernel component
cp "$PRJ_ROOT"/kernel/Image.lz4 kernel.img

# Repack boot.img
avbroot boot pack -o raw.img
avbroot avb pack -o ../boot.modified.img -k "$PRJ_ROOT"/avb.key

# Unpack dtbo.img
mkdir -p "$PRJ_ROOT"/extracted/dtbo
cd "$PRJ_ROOT"/extracted/dtbo
avbroot avb unpack -i ../dtbo.img

# Replace the dtbo image
cp "$PRJ_ROOT"/kernel/dtbo.img raw.img

# Repack dtbo.img
avbroot avb pack -o ../dtbo.modified.img -k "$PRJ_ROOT"/avb.key

# Patch the OTA
cd "$PRJ_ROOT"
avbroot ota patch \
    --input ./original_ota.zip \
    --key-avb ./avb.key \
    --key-ota ./ota.key \
    --cert-ota ./ota.crt \
    --replace boot ./extracted/boot.modified.img \
    --replace dtbo ./extracted/dtbo.modified.img \
    --magisk ./magisk.apk \
    --magisk-preinit-device metadata

