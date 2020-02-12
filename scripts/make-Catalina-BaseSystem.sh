#!/usr/local/bin/bash

cd "${0%/*}" # https://stackoverflow.com/a/16349776

ejectBaseSystem() {
    hdiutil info | grep 'macOS Base System' | awk '{print $1}' | while read -r i; do
        echo 'Unmount BaseSystem Image...'
        hdiutil detach "$i" 2>/dev/null || true
    done
}

function clear_input_buffer_then_read() {
    while read -d '' -r -t 0; do
        read -d '' -t 0.1 -n 10000
        break
    done
    read
}

if [ -s Catalina_BaseSystem-10.15.3.dmg ]; then
    rm Catalina_BaseSystem-10.15.3.dmg
    rm Catalina_BaseSystem-10.15.3.iso
    rm "macOS Base System.dmg"
fi

ejectBaseSystem

echo 'Creating BaseSystem Image...'
hdiutil create -o Catalina_BaseSystem-10.15.3 -size 2GB -layout SPUD -fs HFS+J

echo 'Mounting BaseSystem Image...'
hdiutil attach Catalina_BaseSystem-10.15.3.dmg -noverify -nobrowse -mountpoint /Volumes/Catalina_BaseSystem

#INSTALLERS=/Volumes/Macintosh\ SSD\ -\ Data/Users/rkf/images/installers/
#INSTALLER=$INSTALLERS/Install\ macOS\ Catalina.app
readonly INSTALLER="$(find '/Volumes/Macintosh SSD/Users/rkf/images/installers' -maxdepth 1 -type d -name 'Install macOS Catalina*' -print -quit)"
readonly BOOT_EFI="EFI/boot.efi"

echo 'Restoring BaseSystem to mount point...'
asr restore --source "${INSTALLER}/Contents/SharedSupport/BaseSystem.dmg" \
 --target /Volumes/Catalina_BaseSystem --noprompt --noverify --erase

echo 'Copying boot.efi file...'
# Backup the original files
mv /Volumes/macOS\ Base\ System/usr/standalone/i386/boot.efi /Volumes/macOS\ Base\ System/usr/standalone/i386/_boot.efi
mv /Volumes/macOS\ Base\ System/System/Library/CoreServices/boot.efi /Volumes/macOS\ Base\ System/System/Library/CoreServices/_boot.efi
mv /Volumes/macOS\ Base\ System/System/Library/CoreServices/bootbase.efi /Volumes/macOS\ Base\ System/System/Library/CoreServices/_bootbase.efi

# Copy 10.15 boot.efi file to base system volume
cp $BOOT_EFI /Volumes/macOS\ Base\ System/usr/standalone/i386/
cp $BOOT_EFI /Volumes/macOS\ Base\ System/System/Library/CoreServices/
cp $BOOT_EFI /Volumes/macOS\ Base\ System/System/Library/CoreServices/bootbase.efi

ejectBaseSystem

echo 'Convert dmg to iso...'
hdiutil convert Catalina_BaseSystem-10.15.3.dmg -format UDTO -o Catalina_BaseSystem-10.15.3
mv Catalina_BaseSystem-10.15.3.cdr Catalina_BaseSystem-10.15.3.iso

warning_color="\e[48;2;255;0;0m\e[38;2;255;255;255m"    # white on red
default_color="\033[0m"

echo ''
printf "${warning_color}"'!!!! - MANUAL STEP - !!!!'"${default_color}"'\n'
echo ''
echo '1. Mount the Catalina_BaseSystem-10.15.3.iso image in the Finder'
echo '2. Create an image of the "macOS Base System" disk using Disk utility'
echo '3. Save the file as "macOS Base System.dmg" in the scripts folder'
echo ''
echo 'Press enter to continue'

clear_input_buffer_then_read