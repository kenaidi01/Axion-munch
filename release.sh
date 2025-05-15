#!/bin/bash

OUT_DIR="out/target/product/munch"
ROM_PATH=$(ls -t "$OUT_DIR"/*.zip 2>/dev/null | head -n 1)
ROM_NAME=$(basename "$ROM_PATH")
REPO="kenaidi01/Axion-munch"

# Versi: setelah 'axion-' dan sebelum '-'
ROM_VERSION=$(echo "$ROM_NAME" | sed -n 's/^axion-\([0-9.]*\)-.*/\1/p')
# Channel: setelah versi dan sebelum tanggal (huruf besar, bisa NIGHTLY, STABLE, dll)
CHANNEL=$(echo "$ROM_NAME" | sed -n 's/^axion-[0-9.]*-\([A-Z]*\)-[0-9]\{8\}.*/\1/p')
# Tanggal: 8 digit angka
GIT_TAG=$(echo "$ROM_NAME" | grep -oP '\d{8}' | head -n 1)

if [ ! -f "$ROM_PATH" ]; then
    echo "❌ ROM file not found in $OUT_DIR"
    exit 1
fi

if [ -z "$GIT_TAG" ]; then
    echo "❌ Could not extract date (tag) from ROM name: $ROM_NAME"
    exit 1
fi

if [ -z "$ROM_VERSION" ]; then
    ROM_VERSION="Unknown"
fi

if [ -z "$CHANNEL" ]; then
    CHANNEL="NIGHTLY"
fi

RELEASE_TITLE="AxionOS $ROM_VERSION | $CHANNEL | $GIT_TAG"

# Tambahkan file boot.img, vendor_boot.img, dan dtbo.img jika ada
BOOT_IMG="$OUT_DIR/boot.img"
VENDOR_BOOT_IMG="$OUT_DIR/vendor_boot.img"
DTBO_IMG="$OUT_DIR/dtbo.img"

UPLOAD_ARGS=("$ROM_PATH")
[ -f "$BOOT_IMG" ] && UPLOAD_ARGS+=("$BOOT_IMG")
[ -f "$VENDOR_BOOT_IMG" ] && UPLOAD_ARGS+=("$VENDOR_BOOT_IMG")
[ -f "$DTBO_IMG" ] && UPLOAD_ARGS+=("$DTBO_IMG")

gh release create "$GIT_TAG" "${UPLOAD_ARGS[@]}" \
  --repo "$REPO" \
  --title "$RELEASE_TITLE" \
  --notes "## 📲 Installation Guide

### 🔒 Encrypted Devices (Use OrangeFox Recovery)
1. Flash latest firmware  
2. Flash **AxionOS ROM**  
3. Reflash OrangeFox (or tick 'Reflash after OTA')  
4. Reboot to Recovery  
5. Flash GApps (if you flashed Vanilla ROM)  
6. Format Data  
7. Reboot System  

⚠️ **Important:** Do NOT dirty flash any ROM on TWRP if you're encrypted.

---

### 🔓 Decrypted Devices
1. Flash latest firmware  
2. Flash **AxionOS ROM**  
3. Go to *Advanced > Install Recovery Ramdisk*  
4. Reboot to Recovery  
5. Flash DFE (DFE Neo or RO2RW)  
6. Flash GApps (if you flashed Vanilla ROM)  
7. Format Data (only on first use of DFE)  
8. If already decrypted: Wipe Cache, Dalvik, Metadata, Data  
9. Reboot System  

🔔 **Note:** You must format data if you're using DFE for the first time.
"

echo "✅ Git tag and GitHub release $GIT_TAG completed for $ROM_NAME"
