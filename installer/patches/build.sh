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

# Make overlays again
bash $PWD/build/overlays.sh "" "" $VERSION_NAME $VERSION_CODE

# module.prop
cat <<EOF >${OUTPUT_PATH}/module/META-INF/com/google/android/magisk/module.prop
# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date ${DATE_WITH_TIME}

id=samsung_a70_overlay
name=Samsung Galaxy A70 Overlay
version=V${VERSION_NAME}
versionCode=${VERSION_CODE}
author=Der_Googler
EOF

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

cd "$script_dir"
echo $script_dir

echo "$makes" | while read -r f;do
    name="$(sed -nE 's/LOCAL_PACKAGE_NAME.*:\=\s*(.*)/\1/p' "$f")"
    grep -q treble-overlay <<<"$name" || continue
    echo "Generating $name"
    path="$(dirname "$f")"
    aapt package -f -F "${name}-unsigned.apk" -M "$path/AndroidManifest.xml" -S "$path/res" -I android.jar
    java -jar signapk/signapk.jar keys/platform.x509.pem keys/platform.pk8 "${name}-unsigned.apk" "${name}.apk"
    rm -f "${name}-unsigned.apk"
    APK_OUTPUT_wo_spoof="${PWD}/module/normal/"
    APK_OUTPUT_spoof="${PWD}/module/spoofs/"
    [ ! -d "$APK_OUTPUT_wo_spoof" ] && mkdir -p "$APK_OUTPUT_wo_spoof"
    [ ! -d "$APK_OUTPUT_spoof" ] && mkdir -p "$APK_OUTPUT_spoof"
    if [ "${name}.apk" = "treble-overlay-samsung-a70-systemui.apk" ] || [ "${name}.apk" = "treble-overlay-samsung-a70.apk" ]; then
        mv "${name}.apk" "$APK_OUTPUT_wo_spoof"
    else
        mv "${name}.apk" "$APK_OUTPUT_spoof"
    fi
done

# customize.sh
cat <<EOF >${OUTPUT_PATH}/module/META-INF/com/google/android/magisk/customize.sh
# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date ${DATE_WITH_TIME}

ui_print "-------------------------------------------------- "
ui_print " A70 Overlays     |   Galaxy A70q                  "
ui_print "-------------------------------------------------- "
ui_print " by Der_Googler   |   Version: $VERSION_NAME ($VERSION_CODE)"
ui_print "-------------------------------------------------- "
ui_print " Last build date: ${DATE_WITH_TIME}                "
ui_print "-------------------------------------------------- "
ui_print " "
ui_print "* Module dynamically created on DerGoogler/a70_overlay"
ui_print "* Use only the green FOD color! Others do not work."
ui_print "* Set FOD color to green"
setprop persist.sys.phh.fod_color 00ff00

ui_print "- Do you want to install spoofs?"
ui_print "  Volume up = With Spoofs | Volume down = Without spoofs"
ui_print " "

if \$yes; then
   mode_used="With spoofs"
   package_extract_dir normal "\$MODPATH/system/product/overlay"
   package_extract_dir spoofs "\$MODPATH/system/product/overlay"
else
   mode_used="W/O spoofs"
   package_extract_dir normal "\$MODPATH/system/product/overlay"
fi

# module.prop
cat <<End-of-message >\$MODPATH/module.prop
id=samsung_a70_overlay
name=Samsung Galaxy A70 Overlay (\$mode_used)
version=V${VERSION_NAME}
versionCode=${VERSION_CODE}
author=Der_Googler
description=Fixed Overlay for Samsung Galaxy A70.
support=https://github.com/DerGoogler/a70_overlay
minApi=29
needRamdisk=false
changeBoot=false
End-of-message

ui_print "- Done, installed \$mode_used"
EOF

echo "Building Magisk module"
# Make module.zip
cd module
file="../A70_Overlay_V${VERSION_NAME}(${VERSION_CODE}).zip"
rm -f $file
zip -r $file ./*
