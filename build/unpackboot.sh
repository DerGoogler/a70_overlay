#!/bin/bash

function magisk() {
    adb shell su -c "magisk $@"
}

function dd() {
    
    adb shell su -c "dd $@"
}

function shell() {
    adb shell "su -c \"$@\""
}

MAGISKBOOT="/data/adb/magisk/magiskboot"



shell <<EOF
echo "Go into boot dir"
cd sdcard
echo "Remove latest boot folder, and make new one"
[ -d boot ] && rm -r "boot"
[ ! -d boot ] && mkdir boot
rm -r boot
mkdir boot
cd boot
echo "Unpack boot"
dd if=/dev/block/bootdevice/by-name/boot of=boot.img
$MAGISKBOOT unpack boot.img
echo "Unpack ramdisk.cpio"
$MAGISKBOOT cpio ramdisk.cpio extract
EOF
