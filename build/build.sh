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
        "--local-aapt")
            export LD_LIBRARY_PATH=.
            export PATH=.:$PATH
        ;;
    esac
    shift
done

if [ -z "$VERSION_NAME" ] && [ -z "$VERSION_CODE" ]
then
    echo "Please give an version name and code (--versionName 15 --versionCode 150)"
else
    # module.prop
cat <<EOF >${OUTPUT_PATH}/module/module.prop
id=samsung_a70_overlay
name=Samsung Galaxy A70 Overlay
version=V${VERSION_NAME}
versionCode=${VERSION_CODE}
author=Der_Googler
description=Fixed Overlay for Samsung Galaxy A70. Read DerGoogler/a70_overlay for all spoofs.
EOF
    
    getAPKs="$(ls ${OUTPUT_PATH}/module/system/product/overlay | sed 's/^/ui_print \"* Added /' | sed 's/$/\"/')"
    # customize.sh
cat <<EOF >${OUTPUT_PATH}/module/customize.sh
#!/system/bin/sh

ui_print "* Samsung A70 Overlay V$VERSION_NAME ($VERSION_CODE)"
ui_print "* Last build date: ${DATE_WITH_TIME}"
ui_print "* Module dynamically created on DerGoogler/a70_overlay"
ui_print "* ═══════════════════════════════════════"
${getAPKs}
ui_print "* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
    echo "Building Magisk module"
    # Make module.zip
    cd module
    file="../A70_Overlay_V${VERSION_NAME}(${VERSION_CODE}).zip"
    rm -f $file
    zip -r $file ./*
fi