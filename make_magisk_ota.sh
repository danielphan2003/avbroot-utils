#! /usr/bin/env bash
avbroot ota patch \
    --input ./original_ota.zip \
    --key-avb ./avb.key \
    --key-ota ./ota.key \
    --cert-ota ./ota.crt \
    --magisk ./magisk.apk \
    --magisk-preinit-device metadata

