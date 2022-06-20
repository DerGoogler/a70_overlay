#!/system/bin/sh

# Auto generated while building process, made by Der_Googler <support@dergoogler.com>
# Build date 2022-06-20 / 23:03:29

ui_print "-------------------------------------------------- "
ui_print " A70 Overlays     |   Galaxy A70q                  "
ui_print "-------------------------------------------------- "
ui_print " by Der_Googler   |   Version: 20 (120)            "
ui_print "-------------------------------------------------- "
ui_print " Last build date: 2022-06-20 / 23:03:29            "
ui_print "-------------------------------------------------- "
ui_print " "
ui_print "* Module dynamically created on DerGoogler/a70_overlay"
ui_print "* Use only the green FOD color! Others do not work."
ui_print "- Set FOD color to green"
setprop persist.sys.phh.fod_color 00ff00

ui_print "- Enable overlays"
setprop persist.overlay.dg.enable true

ui_print "- Adding phh-flashlight bin"
chmod +x /system/bin/phh-flashlight
