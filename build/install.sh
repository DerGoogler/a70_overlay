#!/bin/bash

set -e

PWD="$(echo $(pwd))"
FILE="$1"

function su() {
    adb shell su -c "$@"
}

function magisk() {
    adb shell su -c "magisk $@"
}

function push() {
    adb push $@
}

echo "Push $FILE via adb to phone"
push "$PWD/$FILE" "sdcard/Download"

echo "Installing $FILE module"
magisk --install-module "/sdcard/Download/$FILE"