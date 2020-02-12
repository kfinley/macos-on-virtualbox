#!/usr/local/bin/bash

cd "${0%/*}" # https://stackoverflow.com/a/16349776

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

readonly NAME="${NAME:-Install_Catalina-10.15.3}"
readonly INSTALLER="$(find '/Volumes/Macintosh SSD/Users/rkf/images/installers' -maxdepth 1 -type d -name 'Install macOS Catalina*' -print -quit)"
#readonly INSTALLER="/Volumes/Macintosh SSD/Users/rkf/images/installers/Install macOS Catalina.app"
readonly INST_BIN="$INSTALLER/Contents/Resources/createinstallmedia"
readonly DST_DIR="."
readonly DST_DMG="$DST_DIR/$NAME.dmg"
readonly DST_VOL="/Volumes/$NAME"
readonly BOOT_EFI="EFI/boot.efi"

if [ -s "${NAME}.dmg" ]; then
    echo "Deleting ${NAME}.dmg"
    rm "${NAME}.dmg"    
fi

if [ -s "${NAME}.iso" ]; then
    echo "Deleting ${NAME}.iso"
    rm "${NAME}.iso"
fi

ejectInstaller() {
    hdiutil info | grep 'Install macOS Catalina' | awk '{print $1}' | while read -r i; do
        echo 'Unmounting Installer Image...'
        hdiutil detach "$i" 2>/dev/null || true
    done
}

ejectInstaller

echo 'Creating installer image...'
hdiutil create -o "$DST_DMG" -size 10g -layout SPUD -fs HFS+J &&

echo 'Mounting installer image...'
hdiutil attach "$DST_DMG" -mountpoint "$DST_VOL"

echo 'Extracting install files to installer image...'
sudo "$INST_BIN" --nointeraction --volume "$DST_VOL" ||
error "Could create or run installer. Please look in the log file..."

echo 'Replacing boot.efi and BaseSystem.dmg'

# Backup original boot file
mv "/Volumes/Install macOS Catalina/System/Library/CoreServices/boot.efi" "/Volumes/Install macOS Catalina/System/Library/CoreServices/_boot.efi"

# Remove the BaseSystem that won't boot
rm "/Volumes/Install macOS Catalina/Install macOS Catalina.app/Contents/SharedSupport/BaseSystem.dmg"

# Copy the boot.efi that will boot. This is the boot.efi from Catalina 10.15 or Mojave
cp "$BOOT_EFI" "/Volumes/Install macOS Catalina/System/Library/CoreServices/boot.efi"

# Copy a patched version fo the BaseSystem into the installer
cp "macOS Base System.dmg" "/Volumes/Install macOS Catalina/Install macOS Catalina.app/Contents/SharedSupport/BaseSystem.dmg"

echo 'Creating installer image ISO...'
hdiutil makehybrid -iso -udf -iso-volume-name 'Install macOS Catalina' -udf-volume-name 'Install macOS Catalina' -o $NAME.iso '/Volumes/Install macOS Catalina'

ejectInstaller
