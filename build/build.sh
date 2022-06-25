#!/bin/bash

set -e

PWD="$(echo $(pwd))"
DATE_WITH_TIME=`date "+%Y-%m-%d / %H:%M:%S"`

OUTPUT_PATH="${PWD}/build"

while [ "${1:-}" != "" ];
do
    case "$1" in
        "--versionName")
            VERSION_NAME="$2"
        ;;
        "--versionCode")
            VERSION_CODE="$2"
        ;;
        "--name")
            VERSION_NAME="$2"
        ;;
        "--code")
            VERSION_CODE="$2"
        ;;
        "--local-aapt")
            export LD_LIBRARY_PATH=.
            export PATH=.:$PATH
        ;;
    esac
    shift
done

while getopts :n:c: OPTION; do
    case $OPTION in
        n)
            VERSION_NAME="$OPTARG"
        ;;
        c)
            VERSION_CODE="$OPTARG"
        ;;
    esac
done

if [ -z "$VERSION_NAME" ] && [ -z "$VERSION_CODE" ]
then
    echo "Please give an version name and code (--versionName 15 --versionCode 150)"
    exit 1
fi

script_dir="$(dirname "$(readlink -f -- "$0")")"
if [ "$#" -eq 1 ]; then
    if [ -d "$1" ];then
        makes="$(find "$1" -name Android.mk -exec readlink -f -- '{}' \;)"
        
    else
        makes="$(readlink -f -- "$1")"
    fi
else
    cd "$script_dir"
    makes="$(find "$PWD/.." -name Android.mk)"
fi

if ! command -v aapt > /dev/null;then
    export LD_LIBRARY_PATH=.
    export PATH=$PATH:.
fi

if ! command -v aapt > /dev/null;then
    echo "Please install aapt (apt install aapt)"
    exit 1
fi

if ! command -v zip > /dev/null;then
    echo "Please install zip (apt install zip)"
    exit 1
fi

if ! command -v adb > /dev/null;then
    echo "Missing adb binary"
    exit 1
fi

cd "$script_dir"

echo "$makes" | while read -r f;do
    name="$(sed -nE 's/LOCAL_PACKAGE_NAME.*:\=\s*(.*)/\1/p' "$f")"
    grep -q treble-overlay <<<"$name" || continue
    echo "Generating $name"
    path="$(dirname "$f")"
    aapt package -f -F "${name}-unsigned.apk" -M "$path/AndroidManifest.xml" -S "$path/res" -I android.jar --version-name $VERSION_NAME --version-code $VERSION_CODE
    LD_LIBRARY_PATH=./signapk/ java -jar signapk/signapk.jar keys/platform.x509.pem keys/platform.pk8 "${name}-unsigned.apk" "${name}.apk"
    rm -f "${name}-unsigned.apk"
    APK_OUTPUT="$PWD/module/system/product/overlay"
    [ ! -d "$APK_OUTPUT" ] && mkdir -p "$APK_OUTPUT"
    mv "${name}.apk" "$APK_OUTPUT"
done

# customize.sh
cat <<EOF >${OUTPUT_PATH}/module/customize.sh
#!/system/bin/sh

# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date $DATE_WITH_TIME

MAGISKTMP="$(magisk --path)"
get_flags
find_boot_image

exit_ui_print() {
    ui_print "\$1"
    exit
}

if ! command -v /data/adb/magisk/magiskboot > /dev/null;then
    abort "- magiskboot binary not found, exit."
fi

if ! command -v getprop > /dev/null;then
    abort "- getprop binary not found, exit."
fi

# HuskyDG bootloop protector
check_ramdisk() {
ui_print "- Checking ramdisk status"
if [ -e ramdisk.cpio ]; then
  /data/adb/magisk/magiskboot cpio ramdisk.cpio test
  STATUS=\$?
else
  # Stock A only legacy SAR, or some Android 13 GKIs
  STATUS=0
fi
case \$((STATUS & 3)) in
  0 )  # Stock boot
    ui_print "- Stock boot image detected"

    ;;
  1 )  # Magisk patched
    ui_print "- Magisk patched boot image detected"

    ;;
  2 )  # Unsupported
    ui_print "! Boot image patched by unsupported programs"
    exit_ui_print "! Please restore back to stock boot image"
    ;;
esac
}

ui_print "-------------------------------------------------- "
ui_print " A70 Overlays     |   Galaxy A70q                  "
ui_print "-------------------------------------------------- "
ui_print " by Der_Googler   |   Version: $VERSION_NAME ($VERSION_CODE)            "
ui_print "-------------------------------------------------- "
ui_print " Last build date: $DATE_WITH_TIME            "
ui_print "-------------------------------------------------- "
ui_print " "
ui_print "* Module dynamically created on DerGoogler/a70_overlay"
ui_print "* Use only the green FOD color! Others do not work."
ui_print "- Set FOD color to green"
setprop persist.sys.phh.fod_color 00ff00

( if [ ! -z "\$BOOTIMAGE" ]; then
        ui_print "- Target boot image: \$BOOTIMAGE"
        [ "\$RECOVERYMODE" == "true" ] && ui_print "- Recovery mode is present, the script might patch recovery image..."
        mkdir "\$TMPDIR/boot"
        if [ -c "\$BOOTIMAGE" ]; then
            nanddump -f "\$TMPDIR/boot/boot.img" "\$BOOTIMAGE" || exit_ui_print "! Unable to dump boot image"
            BOOTNAND="\$BOOTIMAGE"
            BOOTIMAGE="\$TMPDIR/boot/boot.img"
        else
            dd if="\$BOOTIMAGE" of="\$TMPDIR/boot/boot.img" || exit_ui_print "! Unable to dump boot image"
        fi
        ui_print "- Unpack boot image"
        cd "\$TMPDIR/boot" || exit 1
        /data/adb/magisk/magiskboot unpack boot.img
        check_ramdisk
        ui_print "- Patching \$BOOTIMAGE"

cat <<EUF >a70_overlay.rc
on post-fs-data
    exec u:r:magisk:s0 root root -- /system/bin/sh \\\${MAGISKTMP}/a70_overlay_inject.sh

on property:sys.boot_completed=1
    exec u:r:magisk:s0 root root -- /system/bin/sh \\\${MAGISKTMP}/a70_overlay_inject.sh --notification

EUF

cat <<EUF >a70_overlay_inject.sh
if [ "\$1" == "--notification" ]; then
    if [ ! "\$(getprop persist.sys.overlay.dg.disable.notification)" = "true" ]; then
        su -lp 2000 -c "cmd notification post -S bigtext -t 'A70 Overlay Runtime' 'Tag' 'Overlay sucessfully injected!'"
    fi
else
    cp -af /data/adb/magisk/magiskboot "\\\$POSTFSDIR/magisk/magiskboot"
    cp -af /data/adb/magisk/util_functions.sh "\\\$POSTFSDIR/magisk/util_functions.sh"
    mkdir -p "\\\$MAGISKTMP/.magisk/\${MODPATH##*/}"
    # do not disable overlay
    rm -rf "/data/adb/modules/\${MODPATH##*/}/disable"
    setprop persist.sys.overlay.dg.basic true
    setprop persist.sys.overlay.dg.systemui true
    # always sync module
    if [ -e "\\\$POSTFSDIR/\${MODPATH##*/}/remove" ]; then
        touch "/data/adb/modules/\${MODPATH##*/}/remove"
    else
        mkdir -p "/data/adb/modules/\${MODPATH##*/}"
        cp -af "\\\$MAGISKTMP/samsung_a70_overlay/"* "/data/adb/modules/\${MODPATH##*/}"
        cp -af "\\\$MAGISKTMP/samsung_a70_overlay/"* "\\\$POSTFSDIR"
    fi
fi
EUF

        /data/adb/magisk/magiskboot cpio ramdisk.cpio \\
        "mkdir 0750 overlay.d" \\
        "mkdir 0750 overlay.d/sbin" \\
        "rm -r overlay.d/sbin/a70_overlay" \\
        "mkdir 0750 overlay.d/sbin/a70_overlay" \\
        "add 0750 overlay.d/a70_overlay.rc a70_overlay.rc" \\
        "add 0750 overlay.d/sbin/a70_overlay_inject.sh a70_overlay_inject.sh" \\
        "mkdir 0750 overlay.d/sbin/a70_overlay/system" \\
        "mkdir 0750 overlay.d/sbin/a70_overlay/system/product" \\
        "mkdir 0750 overlay.d/sbin/a70_overlay/system/product/overlay" \\
        "add 0750 overlay.d/sbin/a70_overlay/service.sh \$MODPATH/service.sh" \\
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70-settings.apk \$MODPATH/system/product/overlay/treble-overlay-samsung-a70-settings.apk" \\
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70-systemui.apk \$MODPATH/system/product/overlay/treble-overlay-samsung-a70-systemui.apk" \\
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70-whatsapp.apk \$MODPATH/system/product/overlay/treble-overlay-samsung-a70-whatsapp.apk" \\
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70.apk \$MODPATH/system/product/overlay/treble-overlay-samsung-a70.apk" \\
        "add 0750 overlay.d/sbin/a70_overlay/module.prop \$MODPATH/module.prop"
        ui_print "- Repack boot image"
        /data/adb/magisk/magiskboot repack boot.img || exit_ui_print "! Unable to repack boot image"
        [ -e "\$BOOTNAND" ] && BOOTIMAGE="\$BOOTNAND"
        ui_print "- Flashing new boot image"
        flash_image "\$TMPDIR/boot/new-boot.img" "\$BOOTIMAGE"
        case \$? in
            1)
                exit_ui_print "! Insufficient partition size"
            ;;
            2)
                FILENAME="/sdcard/Download/a70_overlay-patched-boot-\$RANDOM.img"
                cp "\$TMPDIR/boot/new-boot.img" "\$FILENAME"
                ui_print "! \$BOOTIMAGE is read-only"
                ui_print "*****************************************"
                ui_print "    Oops! It seems your boot partition is read-only"
                ui_print "    Saved your boot image to \$FILENAME"
                ui_print "    Please try flashing this boot image from fastboot or recovery"
                ui_print "*****************************************"
                exit_ui_print "! Unable to flash boot image"
            ;;
        esac
        ui_print "- Enable Basic Overlay"
        setprop persist.sys.overlay.dg.basic true

        ui_print "- Enable SystemUI Overlay"
        setprop persist.sys.overlay.dg.systemui true

        ui_print "- All done!"
        su -lp 2000 -c "cmd notification post -S bigtext -t 'A70 Overlay installed' 'Tag' 'Please reboot your device to take effect'"

        ui_print "*****************************************"
        ui_print "  Remember to reinstall module"
        ui_print "      when you flash custom kernel/boot image"
        ui_print "*****************************************"
    else
        ui_print "! Cannot detect target boot image"
fi )
EOF

# service.sh
cat <<EOF >$OUTPUT_PATH/module/service.sh
MODULEDIR=\${0%/*}
MAGISKTMP="$(magisk --path)"

[ -z "\$MAGISKTMP" ] && MAGISKTMP=/sbin

MIRRORPROP="\$MAGISKTMP/.magisk/modules/\${MODULEDIR##*/}/module.prop"
TMPPROP="\$MAGISKTMP/a70_ove.prop"

cat "\$MIRRORPROP" > "\$TMPPROP"

if [ -f "\$MAGISKTMP/samsung_a70_overlay/module.prop" ]; then
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ Overlay installed in boot. \$MESSAGE ] /g" "\$TMPPROP"
fi

mount --bind "\$TMPPROP" "/data/adb/a70_ove/module.prop"

exit
EOF

# module.prop
cat <<EOF >$OUTPUT_PATH/module/module.prop
id=samsung_a70_overlay
name=Samsung Galaxy A70 Overlay
version=V$VERSION_NAME
versionCode=$VERSION_CODE
author=Der_Googler
description=Fixed Overlay for Samsung Galaxy A70.
support=https://github.com/DerGoogler/a70_overlay
minApi=29
needRamdisk=false
changeBoot=true
EOF

echo "Building Magisk module"
# Make module.zip
cd module
file="A70_Overlay_VN$VERSION_NAME-VC$VERSION_CODE.zip"
rm -f "../$file"
zip -r "../$file" ./*
cd ..


ADB=`adb devices | awk 'NR>1 {print $1}'`
if test -n "$ADB"
then
    ( # Isolate
        function magisk() {
            adb shell su -c "magisk $@"
        }
        
        function push() {
            adb push $@
        }
        
        echo "Push $file to $ADB"
        push "$PWD/$file" "sdcard/Download"
        
        echo "Installing $file module on $ADB"
        magisk --install-module "/sdcard/Download/$file"
    )
else
    echo "Can't install module via adb"
    exit $?
fi
