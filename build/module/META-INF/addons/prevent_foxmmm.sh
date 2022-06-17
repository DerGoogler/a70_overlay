# This addon prevent the installation in FoxMMM.
if [ "$MMM_EXT_SUPPORT" = "1" ]; then
    abort "! This module should flashed in Magisk"
    exit 1
fi