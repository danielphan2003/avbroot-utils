#! /usr/bin/env bash
rm -r patched
avbroot ota extract \
    --input ./original_ota.zip.patched \
    --directory patched \
    --all
