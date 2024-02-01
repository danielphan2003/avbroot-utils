#! /usr/bin/env bash

PRJ_ROOT="$(pwd)"
TARGET=""
OUTPUT_DIR=""
ORIGINAL_OTA=""
ORIGINAL_OTA_FILE_NAME=""
ORIGINAL_OTA_NO_EXT=""
MAGISK_APK=""
MAGISK_PREINIT_DEVICE=""
DATE="$(date +%Y-%m-%d_%H-%M-%S)"

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
        --original-ota)
            ORIGINAL_OTA="$2"
            ORIGINAL_OTA_FILE_NAME="${ORIGINAL_OTA##*/}"
            ORIGINAL_OTA_NO_EXT="${ORIGINAL_OTA_FILE_NAME%.*}"
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

if [ -z "$TARGET" ]; then
    echo "Error: --target flag is required."
    exit 1
fi

if [ -z "$OUTPUT_DIR" ]; then
    echo "Error: --output-dir flag is required."
    exit 1
fi

if [ -z "$ORIGINAL_OTA" ]; then
    echo "Error: --original-ota flag is required."
    exit 1
fi

if [ -z "$MAGISK_APK" ]; then
    echo "Error: --magisk-apk flag is required."
    exit 1
fi

if [ -z "$MAGISK_PREINIT_DEVICE" ]; then
    echo "Error: --magisk-preinit-device flag is required."
    exit 1
fi

cd "$PRJ_ROOT"
OUTPUT_OTA="$OUTPUT_DIR/$ORIGINAL_OTA_FILE_NAME.$DATE.magisk.patched"
avbroot ota patch \
    --input "$ORIGINAL_OTA" \
    --output "$OUTPUT_OTA" \
    --key-avb "$TARGET/avb.key" \
    --key-ota "$TARGET/ota.key" \
    --cert-ota "$TARGET/ota.crt" \
    --magisk "$MAGISK_APK" \
    --magisk-preinit-device "$MAGISK_PREINIT_DEVICE"

echo [*] Expect patched OTA: $OUTPUT_OTA

