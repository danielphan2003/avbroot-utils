#! /usr/bin/env bash

PRJ_ROOT="$(pwd)"
TARGET=""
OUTPUT_DIR="$PRJ_ROOT"
KERNEL_ZIP=""
IMAGE=""
DTBO=""
ORIGINAL_OTA=""
ORIGINAL_OTA_FILE_NAME=""
ORIGINAL_OTA_NO_EXT=""
EXTRACTED_ORIGINAL_OTA=""
MAGISK_APK=""
MAGISK_PREINIT_DEVICE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target)
            TARGET="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            mkdir -p "$OUTPUT_DIR"
            shift 2
            ;;
        --kernel-zip)
            KERNEL_ZIP="$2"
            shift 2
            ;;
        --image)
            IMAGE="$2"
            shift 2
            ;;
        --dtbo)
            DTBO="$2"
            shift 2
            ;;
        --original-ota)
            ORIGINAL_OTA="$2"
            ORIGINAL_OTA_FILE_NAME="${ORIGINAL_OTA##*/}"
            ORIGINAL_OTA_NO_EXT="${ORIGINAL_OTA_FILE_NAME%.*}"
            EXTRACTED_ORIGINAL_OTA="$PRJ_ROOT/extracted/$ORIGINAL_OTA_NO_EXT"
            shift 2
            ;;
        --magisk-apk)
            MAGISK_APK="$2"
            shift 2
            ;;
        --magisk-preinit-device)
            MAGISK_PREINIT_DEVICE="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

function prepare () {
    if [ -z "$ORIGINAL_OTA" ]; then
        echo "Error: --original-ota flag is required."
        exit 1
    fi

    if [ -z "$TARGET" ]; then
        echo "Error: --target flag is required."
        exit 1
    fi

    if [ ! -z "$MAGISK_APK" ] && [ -z "$MAGISK_PREINIT_DEVICE" ]; then
        echo "Error: --magisk-preinit-device flag is required when --magisk-apk is specified ($MAGISK_APK)."
        exit 1
    fi

    if [ -z "$KERNEL_ZIP" ]; then
        if [ -z "$IMAGE" ] || [ -z "$DTBO" ]; then
            echo "Error: --image and --dtbo flag is required when --kernel-zip is unspecified."
            exit 1
        fi
    else
        echo [*] Extract kernel zip
        KERNEL_TMP="$(mktemp -d)"
        unzip -j "$KERNEL_ZIP" 'Image.*' -d "$KERNEL_TMP"
        unzip -j "$KERNEL_ZIP" dtbo.img -d "$KERNEL_TMP"

        IMAGE="$(echo $KERNEL_TMP/Image.*)"
        DTBO="$KERNEL_TMP/dtbo.img"
    fi

    echo [*] Image: $IMAGE, dtbo: $DTBO

    if [ ! -d "$EXTRACTED_ORIGINAL_OTA" ]; then
        echo [*] Extract the original OTA to get boot.img and dtbo.img
        avbroot ota extract -i "$ORIGINAL_OTA" -d "$EXTRACTED_ORIGINAL_OTA" --all
    fi
}

function patch_boot () {
    echo [*] Unpack boot.img
    mkdir -p "$EXTRACTED_ORIGINAL_OTA/boot"
    cd "$EXTRACTED_ORIGINAL_OTA/boot"

    avbroot avb unpack -i ../boot.img
    avbroot boot unpack -i raw.img

    echo [*] Replace the kernel component
    mv "$IMAGE" kernel.img

    echo [*] Repack boot.img
    avbroot boot pack -o raw.img
    avbroot avb pack -o ../boot.modified.img -k "$PRJ_ROOT/$TARGET/avb.key"
}

function patch_dtbo () {
    echo [*] Unpack dtbo.img
    mkdir -p "$EXTRACTED_ORIGINAL_OTA/dtbo"
    cd "$EXTRACTED_ORIGINAL_OTA/dtbo"
    avbroot avb unpack -i ../dtbo.img

    echo [*] Replace the dtbo image
    mv "$DTBO" raw.img

    echo [*] Repack dtbo.img
    avbroot avb pack -o ../dtbo.modified.img -k "$PRJ_ROOT/$TARGET/avb.key"
}

function patch_ota () {
    cd "$PRJ_ROOT"
    avbroot ota patch \
        --input "$ORIGINAL_OTA" \
        --key-avb "$TARGET/avb.key" \
        --key-ota "$TARGET/ota.key" \
        --cert-ota "$TARGET/ota.crt" \
        --replace boot "$EXTRACTED_ORIGINAL_OTA/boot.modified.img" \
        --replace dtbo "$EXTRACTED_ORIGINAL_OTA/dtbo.modified.img" \
        "$@"
}

prepare
patch_boot
patch_dtbo

if [ -z "$MAGISK_APK" ]; then
    echo [*] Patch the OTA with custom kernel, no magisk
    patch_ota \
        --output "$OUTPUT_DIR/$ORIGINAL_OTA_FILE_NAME.custom_kernel.patched" \
        --rootless
else
    echo [*] Patch the OTA with custom kernel and magisk: $MAGISK_APK, preinit device: $MAGISK_PREINIT_DEVICE
    patch_ota \
        --output "$OUTPUT_DIR/$ORIGINAL_OTA_FILE_NAME.custom_kernel_magisk.patched" \
        --magisk "$MAGISK_APK" \
        --magisk-preinit-device "$MAGISK_PREINIT_DEVICE"
fi
