# A70 Overlay Installer

## Install

This should only executed in Termux

```bash
# Install proot, bc java not works in normal
pkg install proot
# Install wget if you don't have, or use curl
wget wget https://raw.githubusercontent.com/DerGoogler/a70_overlay/master/installer/install.sh

# Run the installer
proot -0
bash install.sh
```

## Patching build.sh

```bash
bash patchfile.sh
```

## Push files for debugging

```bash
bash push.sh
```
