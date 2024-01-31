#! /usr/bin/env bash
fastboot erase avb_custom_key
fastboot flash avb_custom_key ./avb_pkmd.bin

