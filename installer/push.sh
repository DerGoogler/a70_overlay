#!/bin/bash

# Script used to push the install.sh for debugging

PWD="$(echo $(pwd))"

# Push install.sh
adb push "$PWD/install.sh" "/sdcard" && adb shell su -c "mv \"/sdcard/install.sh\" \"/data/data/com.termux/files/home/\""

# Push build.patch
adb push "$PWD/patches/build.patch" "/sdcard" && adb shell su -c "mv \"/sdcard/build.patch\" \"/data/data/com.termux/files/home/\""