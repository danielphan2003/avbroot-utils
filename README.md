# avbroot-utils

A collection of utilities for [avbroot].

Before executing any of the commands below, please [generate AVB keys] and put the original OTA to `original_ota.zip`.

## 1. `make_ota.sh`,

Create and sign an unpatched OTA from the original OTA.

## 2. or `make_custom_kernel_ota.sh`,

Create and sign a patched OTA with custom kernel and Magisk from the original OTA.

Expects the following files:
- `magisk.apk`: A Magisk apk used to patch the custom kernel.
- `kernel.zip`: A flashable AnyKernel3 zip file to extract the custom kernel from.

## 3. then do the initial setup: `extract_patched.sh` (step 3), `flash_extracted_ota.sh` (step 4), `setup_custom_avb_public_key.sh` (step 5)

Follows [avbroot initial setup] for usage.

Subsequent OTAs does not need this step, as you can use `adb sideload` instead.

[avbroot]: https://github.com/chenxiaolong/avbroot
[generate AVB keys]: https://github.com/chenxiaolong/avbroot#generating-keys
[avbroot initial setup]: https://github.com/chenxiaolong/avbroot#initial-setup

