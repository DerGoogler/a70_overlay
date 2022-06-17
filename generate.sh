#!/bin/bash

PWD="$(echo $(pwd))"
DATE_WITH_TIME=`date "+%Y-%m-%d / %H:%M:%S"`

MANUFACTOR="$1"
DEVICE="$2"
NAME="$3"
CODE="$4"

# Uppercase the first letter
U_MANUFACTOR="$(echo "$MANUFACTOR" | sed 's/.*/\u&/')"
U_DEVICE="$(echo "$DEVICE" | sed 's/.*/\u&/')"



function makeNormal() {
    local OVERLAY_PATH="${PWD}/Base/A70/."
    local OUTPUT_PATH="${PWD}/${U_MANUFACTOR}/${U_DEVICE}/"
    
    [ ! -d "$OUTPUT_PATH" ] && mkdir -p "$OUTPUT_PATH"
    
    cp -R "${OVERLAY_PATH}" "${OUTPUT_PATH}"
    cat <<EOF >${OUTPUT_PATH}/AndroidManifest.xml
<!--
        Generated with generate.sh, made by Der_Googler <support@dergoogler.com>
        Spoof for ${U_MANUFACTOR} ${U_DEVICE}. Build date ${DATE_WITH_TIME}
-->

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="me.phh.treble.overlay.${MANUFACTOR}.${DEVICE}"
        android:versionCode="${CODE}"
        android:versionName="V${NAME}">
        <overlay android:targetPackage="android"
                android:requiredSystemPropertyName="ro.vendor.build.fingerprint"
                android:requiredSystemPropertyValue="+*${MANUFACTOR}/${DEVICE}*"
                android:priority="185"
                android:isStatic="true" />
</manifest>
EOF
    cat <<EOF >${OUTPUT_PATH}/Android.mk
# Generated with generate.sh, made by Der_Googler <support@dergoogler.com>
# Spoof for ${U_MANUFACTOR} ${U_DEVICE}. Build date ${DATE_WITH_TIME}

LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_PACKAGE_NAME := treble-overlay-${MANUFACTOR}-${DEVICE}
LOCAL_MODULE_PATH := \$(TARGET_OUT_PRODUCT)/overlay
LOCAL_IS_RUNTIME_RESOURCE_OVERLAY := true
LOCAL_PRIVATE_PLATFORM_APIS := true
include \$(BUILD_PACKAGE)
EOF
}

function makeSystemUI() {
    local OVERLAY_PATH="${PWD}/Base/A70-SystemUI/."
    local OUTPUT_PATH="${PWD}/${U_MANUFACTOR}/${U_DEVICE}-SystemUI/"
    
    [ ! -d "$OUTPUT_PATH" ] && mkdir -p "$OUTPUT_PATH"
    
    cp -R "${OVERLAY_PATH}" "${OUTPUT_PATH}"
    cat <<EOF >${OUTPUT_PATH}/AndroidManifest.xml
<!--
        Generated with generate.sh, made by Der_Googler <support@dergoogler.com>
        Spoof for ${U_MANUFACTOR} ${U_DEVICE}. Build date ${DATE_WITH_TIME}
-->

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="me.phh.treble.overlay.${MANUFACTOR}.${DEVICE}.systemui"
        android:versionCode="${CODE}"
        android:versionName="V${NAME}">
        <overlay android:targetPackage="com.android.systemui"
                android:targetName="OverlayableResources"
                android:requiredSystemPropertyName="ro.vendor.build.fingerprint"
                android:requiredSystemPropertyValue="+*${MANUFACTOR}/${DEVICE}*"
                android:priority="185"
                android:isStatic="true" />
</manifest>
EOF
    cat <<EOF >${OUTPUT_PATH}/Android.mk
# Generated with generate.sh, made by Der_Googler <support@dergoogler.com>
# Spoof for ${U_MANUFACTOR} ${U_DEVICE}. Build date ${DATE_WITH_TIME}

LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_PACKAGE_NAME := treble-overlay-${MANUFACTOR}-${DEVICE}-systemui
LOCAL_MODULE_PATH := \$(TARGET_OUT_PRODUCT)/overlay
LOCAL_IS_RUNTIME_RESOURCE_OVERLAY := true
LOCAL_PRIVATE_PLATFORM_APIS := true
include \$(BUILD_PACKAGE)
EOF
}

if [ -z "$1" ] && [ -z "$2" ]
then
    echo "Please give an manufactor and device name!"
    exit 1
fi

# $1 MANUFACTOR
# $2 DECIVE
# $3 VERSION_NAME
# $4 VERSION_CODE

makeSystemUI $1 $2 $3 $4
makeNormal $1 $2 $3 $4
