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

echo [*] Flashing OTA in fastboot mode...
for image in extracted/"$PATCHED_OTA_NO_EXT"/*.img; do
    partition=$(basename "${image}")

    if [ "$partition" == "system" ]; then
        echo [*] Skipping system image. This will need to be flashed later.
        continue
    fi

    partition=${partition%.img}
    fastboot flash "${partition}" "${image}"
done

echo [*] Preparing to flash system image in recovery\'s fastbootd mode
echo [*] WARNING: This stage can potentially hard brick your device. Please confirm your option.

# Function to display the confirmation prompt
function confirm() {
    while true; do
        IFS= read -rp "Do you want to proceed? ([Y/y]ES or [N/n]O or [C/c]ANCEL) " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            [Cc]* ) return 1;;
            * ) echo "Please answer YES, NO, or CANCEL.";;
        esac
    done
}

if confirm; then
    echo " => User chose YES. Executing the operation..."

    echo [*] Rebooting to recovery\'s fastbootd mode
    echo -n "     in"
    for count in {5..1}; do
        echo -n " .. $count seconds"
        sleep 1
    done
    echo

    fastboot reboot fastboot

    echo [*] Rebooted to recovery\'s fastbootd mode. Flashing system image
    echo -n "     in"
    for count in {5..1}; do
        echo -n " .. $count seconds"
        sleep 1
    done
    echo

    fastboot flash system extracted/"$PATCHED_OTA_NO_EXT"/system.img
    echo [*] Completed flashing system image
else
    echo " => User chose NO/CANCEL. Aborting the operation..."
    echo "[*] DO NOT RESTART YOUR DEVICE IF YOU ARE NOT SURE ABOUT ANTI ROLLBACK PROTECTION (ARP)."
    echo " => It is recommended to double check your device's current OTA and the OTA that you are flashing have the same security patch, to prevent triggering ARP and hard bricking your device."
    echo " => If you are not sure, please repatch another OTA that matches the same security patch that your device's current OTA has."
    exit 1
fi
