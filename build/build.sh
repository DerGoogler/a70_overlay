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

ui_print "- Enable overlays"
setprop persist.overlay.dg.enable true

ui_print "- Adding phh-flashlight bin"
chmod +x $MODPATH/system/bin/phh-flashlight
EOF

# customize.sh
cat <<EOF >${OUTPUT_PATH}/module/system/bin/phh-flashlight
#!/system/bin/sh

if ! command -v am > /dev/null;then
    echo "am binary not found, exit."
    exit 1
fi

broadcast() {
    am broadcast \$@
}

if [ -z "\$1" ]; then
    echo "Missing args, exit."
    exit 1
fi

while [ "\${1:-}" != "" ];
do
    case "\$1" in
        "--enable")
            broadcast  -n "com.dergoogler.phh.flashlight/com.dergoogler.phh.flashlight.Receivers.FlashlightReceiver" --ez enable \$2
        ;;
        "--version")
            echo "V$VERSION_NAME ($VERSION_CODE)"
        ;;
    esac
    shift
done
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
changeBoot=false
EOF

echo "Building Magisk module"
# Make module.zip
cd module
file="A70_Overlay_VN$VERSION_NAME-VC$VERSION_CODE.zip"
rm -f "../$file"
zip -r "../$file" ./*
cd ..

bash $PWD/install.sh $file