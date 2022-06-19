# A70 Overlay

Magisk module uses Dynamic Installer and should only flashed in Magisk

## Supported Spoofs

- [x] Google Pixel 3a XL
- [x] Google Pixel 4a
- [x] Google Pixel 4 XL
- [x] Google Pixel 5
- [x] Google Pixel 6a (Leak)
- [x] Google Pixel 6 Pro
- [x] Google Pixel 7 Pro (Leak)

---

- [x] Samsung Galaxy A70

## Generate overlay

Removed. It's now universal

## Build?

```bash
# run
cd build
bash build.sh --versionName 17 --versionCode 170
# or
bash build.sh -n 17 -c 170
```

> You don't know how to do that? Then don't do it.

## Others

I was bored, so I created some funny/cringe stuff

All changes needs reboot
```bash
# Cringe Settings
su -c "setprop persist.overlay.dg.settigns.cringe true"

# Cringe WhatsApp (I've warn you)

su -c "setprop persist.overlay.dg.whatsapp.cringe true"
```
