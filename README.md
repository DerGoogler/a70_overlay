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

```bash
# Generate overlay
bash build/generate.sh google raven

# Generate via device props
bash build/generate.sh fingerprint
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
