#!/bin/bash

PWD="$(echo $(pwd))"
DATE_WITH_TIME=`date "+%Y-%m-%d / %H:%M:%S"`

function makeNormal() {
    MANUFACTOR="$1"
    DEVICE="$2"
    
    # Uppercase the first letter
    U_MANUFACTOR="$(echo "$MANUFACTOR" | sed 's/.*/\u&/')"
    U_DEVICE="$(echo "$DEVICE" | sed 's/.*/\u&/')"
    
    OVERLAY_PATH="${PWD}/Samsung/A70/."
    OUTPUT_PATH="${PWD}/${U_MANUFACTOR}/${U_DEVICE}/"
    
    cp -R "${OVERLAY_PATH}" "${OUTPUT_PATH}"
    cat <<EOF >${OUTPUT_PATH}/AndroidManifest.xml
<!--
        Generated with generate.sh, made by Der_Googler <support@dergoogler.com>
        Spoof for ${U_MANUFACTOR} ${U_DEVICE}. Build date ${DATE_WITH_TIME}
-->

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="me.phh.treble.overlay.${MANUFACTOR}.${DEVICE}"
        android:versionCode="1"
        android:versionName="1.0">
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
    MANUFACTOR="$1"
    DEVICE="$2"
    
    # Uppercase the first letter
    U_MANUFACTOR="$(echo "$MANUFACTOR" | sed 's/.*/\u&/')"
    U_DEVICE="$(echo "$DEVICE" | sed 's/.*/\u&/')"
    
    OVERLAY_PATH="${PWD}/Samsung/A70-SystemUI/."
    OUTPUT_PATH="${PWD}/${U_MANUFACTOR}/${U_DEVICE}-SystemUI/"
    
    cp -R "${OVERLAY_PATH}" "${OUTPUT_PATH}"
    cat <<EOF >${OUTPUT_PATH}/AndroidManifest.xml
<!--
        Generated with generate.sh, made by Der_Googler <support@dergoogler.com>
        Spoof for ${U_MANUFACTOR} ${U_DEVICE}. Build date ${DATE_WITH_TIME}
-->

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="me.phh.treble.overlay.${MANUFACTOR}.${DEVICE}.systemui"
        android:versionCode="1"
        android:versionName="1.0">
        <overlay android:targetPackage="com.android.systemui"
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

while [ "${1:-}" != "" ];
do
    case "$1" in
        "--systemui")
            makeSystemUI $2 $3
        ;;
        "--normal")
            makeNormal $2 $3
        ;;
    esac
    shift
done

