# avbroot-utils

A collection of utilities for [avbroot].

Before executing any of the commands below, please [generate AVB keys] and put the original OTA to `original_ota.zip`.

If you intend to use Magisk, please follow [Magisk preinit device guide] and edit the preinit device that is used in option 2 and option 3.

## Option 1: `make_normal_ota.sh`

Create and sign an OTA without any modifications.

## Option 2: `make_custom_kernel_ota.sh`

Create and sign an OTA with custom kernel and optionally Magisk from the original OTA.

Expects the following files:
- `magisk.apk`: A Magisk apk used to patch the custom kernel. Unused if `--magisk` is not specified.
- `kernel.zip`: A flashable AnyKernel3 zip file to extract the custom kernel from.

## Option 3: `make_magisk_ota.sh`

Create and sign an OTA with Magisk.

Expects the following files:
- `magisk.apk`: A Magisk apk used to patch the custom kernel.

## Finally: Do the initial setup in order

- `extract_patched.sh` (step 3 of the avbroot initial setup),
- `flash_extracted_ota.sh` (step 4 of the avbroot initial setup),
- `setup_custom_avb_public_key.sh` (step 5 of the avbroot initial setup).

Follows [avbroot initial setup] for further usage.

Subsequent OTAs does not need this step, as you can rerun option 1/2/3 of this guide and use `adb sideload` to flash the patched OTA.

[avbroot]: https://github.com/chenxiaolong/avbroot
[generate AVB keys]: https://github.com/chenxiaolong/avbroot#generating-keys
[Magisk preinit device guide]: https://github.com/chenxiaolong/avbroot#magisk-preinit-device
[avbroot initial setup]: https://github.com/chenxiaolong/avbroot#initial-setup

