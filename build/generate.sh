#!/bin/bash

PWD="$(echo $(pwd))"
DATE_WITH_TIME=`date "+%Y-%m-%d / %H:%M:%S"`

function getprop() {
    adb shell getprop $1
}

if [ "$1" = "fingerprint" ]; then
    MANUFACTOR="$(getprop ro.product.product.brand)"
    DEVICE="$(getprop ro.product.product.device)"
    NAME="${NAME:=10}"
    CODE="${CODE:=100}"
else
    MANUFACTOR="$1"
    DEVICE="$2"
    NAME="${NAME:=10}"
    CODE="${CODE:=100}"
fi

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

if [ -z "$MANUFACTOR" ] && [ -z "$DEVICE" ]
then
    echo "Please give an manufactor and device name!"
    exit 1
fi

makeSystemUI && makeNormal
