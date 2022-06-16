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
make overlays name="${VERSION_NAME}" code="${VERSION_CODE}"

# module.prop
cat <<EOF >${OUTPUT_PATH}/module/module.prop
# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date ${DATE_WITH_TIME}

id=samsung_a70_overlay
name=Samsung Galaxy A70 Overlay
version=V${VERSION_NAME}
versionCode=${VERSION_CODE}
author=Der_Googler
description=Fixed Overlay for Samsung Galaxy A70. Read DerGoogler/a70_overlay for all spoofs.
support=https://github.com/DerGoogler/a70_overlay
minApi=29
needRamdisk=false
changeBoot=false

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

echo "$makes" | while read -r f;do
    name="$(sed -nE 's/LOCAL_PACKAGE_NAME.*:\=\s*(.*)/\1/p' "$f")"
    grep -q treble-overlay <<<"$name" || continue
    echo "Generating $name"
    
    path="$(dirname "$f")"
    aapt package -f -F "${name}-unsigned.apk" -M "$path/AndroidManifest.xml" -S "$path/res" -I android.jar
    LD_LIBRARY_PATH=./signapk/ java -jar signapk/signapk.jar keys/platform.x509.pem keys/platform.pk8 "${name}-unsigned.apk" "${name}.apk"
    rm -f "${name}-unsigned.apk"
    mv "${name}.apk" "${PWD}/module/system/product/overlay/"
done

# customize.sh
cat <<EOF >${OUTPUT_PATH}/module/customize.sh
#!/system/bin/sh

# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date ${DATE_WITH_TIME}

# Clear terminal after 3 seconds
sleep 3
clear

print "* Samsung A70 Overlay V$VERSION_NAME ($VERSION_CODE)"
print "* Last build date: ${DATE_WITH_TIME}"
print "* Module dynamically created on DerGoogler/a70_overlay"
print "! Use only the green FOD color! Others do not work."
print "- Set FOD color to green"

setprop persist.sys.phh.fod_color 00ff00

print "* ═══════════════════════════════════════"
$(ls ${OUTPUT_PATH}/module/system/product/overlay | sed 's/^/print \"* Added /' | sed 's/$/\"/')
print "* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

EOF

echo "Building Magisk module"
# Make module.zip
cd module
file="../A70_Overlay_V${VERSION_NAME}(${VERSION_CODE}).zip"
rm -f $file
zip -r $file ./*