#!/system/bin/sh

# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date 2022-06-24 / 16:52:43

MAGISKTMP=""
get_flags
find_boot_image

exit_ui_print() {
    ui_print "$1"
    exit
}

if ! command -v /data/adb/magisk/magiskboot > /dev/null;then
    abort "- magiskboot binary not found, exit."
fi

# HuskyDG bootloop protector
check_ramdisk() {
ui_print "- Checking ramdisk status"
if [ -e ramdisk.cpio ]; then
  /data/adb/magisk/magiskboot cpio ramdisk.cpio test
  STATUS=$?
else
  # Stock A only legacy SAR, or some Android 13 GKIs
  STATUS=0
fi
case $((STATUS & 3)) in
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
ui_print " by Der_Googler   |   Version: 21 (121)            "
ui_print "-------------------------------------------------- "
ui_print " Last build date: 2022-06-24 / 16:52:43            "
ui_print "-------------------------------------------------- "
ui_print " "
ui_print "* Module dynamically created on DerGoogler/a70_overlay"
ui_print "* Use only the green FOD color! Others do not work."
ui_print "- Set FOD color to green"
setprop persist.sys.phh.fod_color 00ff00

( if [ ! -z "$BOOTIMAGE" ]; then
        ui_print "- Target boot image: $BOOTIMAGE"
        [ "$RECOVERYMODE" == "true" ] && ui_print "- Recovery mode is present, the script might patch recovery image..."
        mkdir "$TMPDIR/boot"
        if [ -c "$BOOTIMAGE" ]; then
            nanddump -f "$TMPDIR/boot/boot.img" "$BOOTIMAGE" || exit_ui_print "! Unable to dump boot image"
            BOOTNAND="$BOOTIMAGE"
            BOOTIMAGE="$TMPDIR/boot/boot.img"
        else
            dd if="$BOOTIMAGE" of="$TMPDIR/boot/boot.img" || exit_ui_print "! Unable to dump boot image"
        fi
        ui_print "- Unpack boot image"
        cd "$TMPDIR/boot" || exit 1
        /data/adb/magisk/magiskboot unpack boot.img
        check_ramdisk
        ui_print "- Patching $BOOTIMAGE"

cat <<EUF >a70_overlay.rc
on post-fs-data
    exec u:r:magisk:s0 root root -- /system/bin/sh \${MAGISKTMP}/a70_overlay_inject.sh

EUF

cat <<EUF >a70_overlay_inject.sh
cp -af /data/adb/magisk/magiskboot "\$POSTFSDIR/magisk/magiskboot"
cp -af /data/adb/magisk/util_functions.sh "\$POSTFSDIR/magisk/util_functions.sh"
mkdir -p "\$MAGISKTMP/.magisk/${MODPATH##*/}"
# do not disable overlay
rm -rf "/data/adb/modules/${MODPATH##*/}/disable"
# always sync module
if [ -e "\$POSTFSDIR/${MODPATH##*/}/remove" ]; then
    touch "/data/adb/modules/${MODPATH##*/}/remove"
else
    mkdir -p "/data/adb/modules/${MODPATH##*/}"
    cp -af "\$MAGISKTMP/samsung_a70_overlay/"* "/data/adb/modules/${MODPATH##*/}"
    cp -af "\$MAGISKTMP/samsung_a70_overlay/"* "\$POSTFSDIR"
fi
EUF

        /data/adb/magisk/magiskboot cpio ramdisk.cpio \
        "mkdir 0750 overlay.d" \
        "mkdir 0750 overlay.d/sbin" \
        "rm -r overlay.d/sbin/a70_overlay" \
        "mkdir 0750 overlay.d/sbin/a70_overlay" \
        "add 0750 overlay.d/a70_overlay.rc a70_overlay.rc" \
        "add 0750 overlay.d/sbin/a70_overlay_inject.sh a70_overlay_inject.sh" \
        "mkdir 0750 overlay.d/sbin/a70_overlay/system" \
        "mkdir 0750 overlay.d/sbin/a70_overlay/system/product" \
        "mkdir 0750 overlay.d/sbin/a70_overlay/system/product/overlay" \
        "add 0750 overlay.d/sbin/a70_overlay/service.sh $MODPATH/service.sh" \
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70-settings.apk $MODPATH/system/product/overlay/treble-overlay-samsung-a70-settings.apk" \
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70-systemui.apk $MODPATH/system/product/overlay/treble-overlay-samsung-a70-systemui.apk" \
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70-whatsapp.apk $MODPATH/system/product/overlay/treble-overlay-samsung-a70-whatsapp.apk" \
        "add 0750 overlay.d/sbin/a70_overlay/system/product/overlay/treble-overlay-samsung-a70.apk $MODPATH/system/product/overlay/treble-overlay-samsung-a70.apk" \
        "add 0750 overlay.d/sbin/a70_overlay/module.prop $MODPATH/module.prop"
        ui_print "- Repack boot image"
        /data/adb/magisk/magiskboot repack boot.img || exit_ui_print "! Unable to repack boot image"
        [ -e "$BOOTNAND" ] && BOOTIMAGE="$BOOTNAND"
        ui_print "- Flashing new boot image"
        flash_image "$TMPDIR/boot/new-boot.img" "$BOOTIMAGE"
        case $? in
            1)
                exit_ui_print "! Insufficient partition size"
            ;;
            2)
                FILENAME="/sdcard/Download/a70_overlay-patched-boot-$RANDOM.img"
                cp "$TMPDIR/boot/new-boot.img" "$FILENAME"
                ui_print "! $BOOTIMAGE is read-only"
                ui_print "*****************************************"
                ui_print "    Oops! It seems your boot partition is read-only"
                ui_print "    Saved your boot image to $FILENAME"
                ui_print "    Please try flashing this boot image from fastboot or recovery"
                ui_print "*****************************************"
                exit_ui_print "! Unable to flash boot image"
            ;;
        esac
        ui_print "- Enable overlays"
        setprop persist.overlay.dg.enable true
        ui_print "- All done!"

        ui_print "*****************************************"
        ui_print "  Remember to reinstall module"
        ui_print "      when you flash custom kernel/boot image"
        ui_print "*****************************************"
    else
        ui_print "! Cannot detect target boot image"
fi )
