# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date 2022-06-19 / 14:26:44

ui_print "-------------------------------------------------- "
ui_print " A70 Overlays     |   Galaxy A70q                  "
ui_print "-------------------------------------------------- "
ui_print " by Der_Googler   |   Version: 20 (120)"
ui_print "-------------------------------------------------- "
ui_print " Last build date: 2022-06-19 / 14:26:44                "
ui_print "-------------------------------------------------- "
ui_print " "
ui_print "* Module dynamically created on DerGoogler/a70_overlay"
ui_print "* Use only the green FOD color! Others do not work."
ui_print "* Set FOD color to green"
setprop persist.sys.phh.fod_color 00ff00

ui_print "- Do you want to install spoofs?"
ui_print "  Volume up = With Spoofs | Volume down = Without spoofs"
ui_print " "

if $yes; then
   mode_used="With spoofs"
   package_extract_dir normal "$MODPATH/system/product/overlay"
   package_extract_dir spoofs "$MODPATH/system/product/overlay"
else
   mode_used="W/O spoofs"
   package_extract_dir normal "$MODPATH/system/product/overlay"
fi

# module.prop
cat <<End-of-message >$MODPATH/module.prop
id=samsung_a70_overlay
name=Samsung Galaxy A70 Overlay ($mode_used)
version=V20
versionCode=120
author=Der_Googler
description=Fixed Overlay for Samsung Galaxy A70.
support=https://github.com/DerGoogler/a70_overlay
minApi=29
needRamdisk=false
changeBoot=false
End-of-message

ui_print "- Done, installed $mode_used"
