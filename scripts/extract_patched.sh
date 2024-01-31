#! /usr/bin/env bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --patched-ota)
            PATCHED_OTA="$2"
	    PATCHED_OTA_FILE_NAME="${PATCHED_OTA##*/}"
            PATCHED_OTA_NO_EXT="${PATCHED_OTA_FILE_NAME%.*}"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

if [ -z "$PATCHED_OTA" ]; then
    echo "Error: --patched-ota flag is required."
    exit 1
fi

mkdir -p "extracted/$PATCHED_OTA_NO_EXT"
avbroot ota extract \
    --input "$PATCHED_OTA" \
    --directory "extracted/$PATCHED_OTA_NO_EXT" \
    --all
