#! /usr/bin/env bash
for image in extracted/*.img; do
    partition=$(basename "${image}")
    partition=${partition%.img}

    fastboot flash "${partition}" "${image}"
done

