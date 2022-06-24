# A70 Overlay

Fixed Overlay for Samsung Galaxy A70 with boot injection.

## Enable

I was bored, so I created some funny/cringe stuff

All changes needs reboot

```bash
# Cringe Settings
su -c "setprop persist.sys.overlay.dg.settigns.cringe true"

# Cringe WhatsApp (I've warn you)

su -c "setprop persist.sys.overlay.dg.whatsapp.cringe true"
```

## Build?

```bash
# run
cd build
bash build.sh --versionName 17 --versionCode 170
# or
bash build.sh -n 17 -c 170
```

> You don't know how to do that? Then don't do it.

# Credits

- [HuskyDG](https://github.com/HuskyDG) Inject into boot core
