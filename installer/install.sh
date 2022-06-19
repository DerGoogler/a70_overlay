#!/bin/bash

set -e

PWD="$(echo $(pwd))"
# Temp folder
TMP="/data/local/tmp"

if [ ! "$PREFIX" = "/data/data/com.termux/files/usr" ]; then
    echo "This is only runable in Termux"
    exit 1
fi

if ! command -v su > /dev/null;then
    echo "Your device don't have root access"
    exit 1
fi

# Automatic install
for bin in git zip aapt wget proot
do
    if ! command -v $bin > /dev/null;then
        echo "Installing $bin"
        pkg install $bin
        # Uncomment the following if pkg isn't working
        # apt install $bin
        # apt-get install $bin
    fi
done

# Launch fake root
proot -0

# Docs: https://github.com/MasterDevX/Termux-Java
# Java install
if ! command -v java > /dev/null;then
    echo "Installing Java"
    wget https://raw.githubusercontent.com/MasterDevX/java/master/installjava && bash installjava
fi

# Override java binary
function java() {
    proot -q java
}

# Override su binary
function su() {
    su -c $@
}

# Override magisk binary
function magisk() {
    magisk $@
}

BUILD_PATH="$PWD/a70_overlay"
echo "Checking if destination exist"
if [ ! -d "$BUILD_PATH" ]; then
    echo "Clone DerGoogler/a70_overlay"
    git clone https://github.com/DerGoogler/a70_overlay.git
else
    echo "$BUILD_PATH already exist"
fi

# Go to destination
cd $PWD/a70_overlay

# Set version (is required to copy the output zip)
VERSION_NAME="20"
VERSION_CODE="120"

# Patch out some sht
# patch -u "$PWD/build/build.sh" -i "$HOME/build.patch"

# Make overlays
$PWD/build/build.sh --versionName 20 --versionCode 120

# Copy to temp destination
echo "Copy zip file into temp folder"
su cp $PWD/build/A70_Overlay_V$VERSION_NAME($VERSION_CODE).zip $TMP/A70_Overlay_V$VERSION_NAME($VERSION_CODE).zip

