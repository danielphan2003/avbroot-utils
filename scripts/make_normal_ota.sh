#! /usr/bin/env bash

PRJ_ROOT="$(pwd)"
TARGET=""
OUTPUT_DIR=""
ORIGINAL_OTA=""
ORIGINAL_OTA_FILE_NAME=""
ORIGINAL_OTA_NO_EXT=""
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

cd "$PRJ_ROOT"
OUTPUT_OTA="$OUTPUT_DIR/$ORIGINAL_OTA_FILE_NAME.$DATE.normal.patched"
avbroot ota patch \
    --input "$ORIGINAL_OTA" \
    --output "$OUTPUT_OTA" \
    --key-avb "$TARGET/avb.key" \
    --key-ota "$TARGET/ota.key" \
    --cert-ota "$TARGET/ota.crt" \
    --rootless

echo [*] Expect patched OTA: $OUTPUT_OTA

