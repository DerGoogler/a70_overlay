MODULEDIR=${0%/*}
MAGISKTMP=""

[ -z "$MAGISKTMP" ] && MAGISKTMP=/sbin

MIRRORPROP="$MAGISKTMP/.magisk/modules/${MODULEDIR##*/}/module.prop"
TMPPROP="$MAGISKTMP/a70_ove.prop"

cat "$MIRRORPROP" > "$TMPPROP"

if [ -f "$MAGISKTMP/samsung_a70_overlay/module.prop" ]; then
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ Overlay installed in boot. $MESSAGE ] /g" "$TMPPROP"
fi

mount --bind "$TMPPROP" "/data/adb/a70_ove/module.prop"

exit
