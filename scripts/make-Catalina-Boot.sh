#!/usr/local/bin/bash

cd "${0%/*}" # https://stackoverflow.com/a/16349776

if [ -s Catalina_Boot_Image.dmg ]; then
    rm Catalina_Boot_Image.dmg
fi

if [ -s Catalina_Boot_Image.iso ]; then
    rm Catalina_Boot_Image.iso
fi

hdiutil info | grep 'Catalina_Boot_Image' | awk '{print $1}' | while read -r i; do
    hdiutil detach "$i" 2>/dev/null || true
done

echo 'Creating Boot Image...'
hdiutil create -o Catalina_Boot_Image -size 100m -layout SPUD -fs HFS+J

echo 'Mounting Boot Image...'
hdiutil attach Catalina_Boot_Image.dmg -noverify -nobrowse -mountpoint /Volumes/Catalina_Boot_Image

SOURCE_DIR=".."

echo 'Copying files to Boot Image...'
# create efi boot image from .viso file
cp "${SOURCE_DIR}/Catalina_BaseSystem.chunklist" /Volumes/Catalina_Boot_Image/BaseSystem.chunklist
cp "${SOURCE_DIR}/Catalina_InstallInfo.plist" /Volumes/Catalina_Boot_Image/InstallInfo.plist
cp "${SOURCE_DIR}/Catalina_AppleDiagnostics.dmg" /Volumes/Catalina_Boot_Image/AppleDiagnostics.dmg
cp "${SOURCE_DIR}/Catalina_AppleDiagnostics.chunklist" /Volumes/Catalina_Boot_Image/AppleDiagnostics.chunklist
mkdir /Volumes/Catalina_Boot_Image/EFI
mkdir /Volumes/Catalina_Boot_Image/EFI/NVRAM
cp "${SOURCE_DIR}/macOS-Catalina_MLB.bin" /Volumes/Catalina_Boot_Image/EFI/NVRAM/MLB.bin
cp "${SOURCE_DIR}/macOS-Catalina_ROM.bin" /Volumes/Catalina_Boot_Image/EFI/NVRAM/ROM.bin
cp "${SOURCE_DIR}/macOS-Catalina_csr-active-config.bin" /Volumes/Catalina_Boot_Image/EFI/NVRAM/csr-active-config.bin
cp "${SOURCE_DIR}/macOS-Catalina_system-id.bin" /Volumes/Catalina_Boot_Image/EFI/NVRAM/system-id.bin
mkdir /Volumes/Catalina_Boot_Image/EFI/OC
mkdir /Volumes/Catalina_Boot_Image/EFI/OC/Drivers
cp "${SOURCE_DIR}/ApfsDriverLoader.efi" /Volumes/Catalina_Boot_Image/EFI/OC/Drivers/ApfsDriverLoader.efi
cp "${SOURCE_DIR}/AppleImageLoader.efi" /Volumes/Catalina_Boot_Image/EFI/OC/Drivers/AppleImageLoader.efi
cp "${SOURCE_DIR}/AppleUiSupport.efi" /Volumes/Catalina_Boot_Image/EFI/OC/Drivers/AppleUiSupport.efi
cp "${SOURCE_DIR}/macOS-Catalina_startup.nsh" /Volumes/Catalina_Boot_Image/startup.nsh

echo 'Creating Boot Image ISO...'
# Create an iso off the mounted image using makeybrid so we can set the volume name used when mounted under BaseSystem
hdiutil makehybrid -iso -udf -iso-volume-name Catalina_Boot_Image -udf-volume-name Catalina_Boot_Image -o Catalina_Boot_Image.iso /Volumes/Catalina_Boot_Image

echo 'Unmounting Boot Image...'
hdiutil info | grep 'Catalina_Boot_Image' | awk '{print $1}' | while read -r i; do
    hdiutil detach "$i" 2>/dev/null || true
done

#Party!