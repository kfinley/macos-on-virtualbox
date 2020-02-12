# Run MacOS Catalina (10.15.13) Guest on VirtualBox

Install MacOS Catalina 10.15.3 with one command:

`$ make catalina`

This project will help you install MacOS Catalina 10.15.3 as a guest on VirtualBox (currently only tested on MacOS). The process will partially-automate the MacOS Catalina 10.15.3 Install and requires some user interaction.

This project is a fork / merge / modification of the following projects:

- [myspaghetti/macos-guest-virtualbox](https://github.com/myspaghetti/macos-guest-virtualbox)
- [AlexanderWillner/runMacOSinVirtualBox](https://github.com/AlexanderWillner/runMacOSinVirtualBox)

This project is a ~~fragile~~ work in progress process and hopefully most of it won't be needed once VirtualBox fixes the EFI boot issue. As the state of the EFI issue evolves this project will be cleaned up and evolve as well... :)

### Overview
In working through the issue of installing MacOS Catalina 10.15.3 on VirtualBox I (like many others) ran into a [bug in VirtualBox](https://www.virtualbox.org/ticket/19188#comment:8) that prevents MacOS 10.15.2+ installations from booting. (Scheduled to be fixed in the next maintenance release). 

**Problem:** The `boot.efi` file from the MacOS 10.15.2+ installer and Base System will not boot on VirtualBox.

**Solution**: In order to install MacOS 10.15.2+ you must boot using the `boot.efi` from a MacOS 10.15.1 (or older) installation or Base System. Additionally the 10.15.3 Base System and MacOS Installer app can be patched using an older `boot.efi` which reduces steps to install.

This project has scripts that will create a new MacOS 10.15.3 Installer and Base System images as well as an EFI Boot image. A working `boot.efi` file will be injected into the installer and Base System. This installer and Base System will then be used to create a new VM and install MacOS 10.15.3 on it in a partially-automated fashion.

***Why is this even needed?***
I use this for dotfiles development, maintenance, and testing mostly...

***Are you really running MacOS in VirtualBox?***
No, I don't use it for regular day-to-day use.

### Required Software & components
- [MacOS Catalina Installer](https://apps.apple.com/us/app/macos-catalina/id1466841314?mt=12)
- VirtualBox
- VirtualBox Extension Pack (note: released under the Personal Use and Evaluation License)
- `boot.efi` file from MacOS 10.15.1 (10.15 and Mojave files work as well)
- csplit
- gzip
- xxd
- unzip
- wget

### Configuration & Setup
You will need the [MacOS Catalina Installer](https://apps.apple.com/us/app/macos-catalina/id1466841314?mt=12) under the Applications folder (or change the location in `scripts/make-Catalina-Installer.sh`).

You will also need the `boot.efi` file from MacOS 10.15.1 or lower. Place the file in the directory `scripts/EFI`. If you don't already have the file you can extract it from the [MacOS Mojave installer](https://itunes.apple.com/us/app/macos-mojave/id1398502828?mt=12).

The `macos-on-virtualbox.sh`, `scripts/make-Catalina-Installer.sh`, and `scripts/make-Catalina-Boot.sh` scripts each contain settings that should be reviewed before running.

Once you have the required software, files, and configurations set use `make` to handle the setup process. It's highly recommended that you run `make check` to confirm your system has all the required dependencies installed before running `make catalina`.

Execute `make` for details on how to run the full installation process.

```
$ make
Steps to install Catalina: make COMMAND
   COMMAND	  Description
 - check	: Check required dependencies are installed
 - catalina	: Create VM & disks, partition HD, init installer, fix startup, run installer, fix Preboot, and start Catalina
 - delete	: Delete exiting vm
 - clean	: Delete temporary files (currently busted...)
 ```

### How does it work?
The `macos-on-virtualbox` script does most of the work for creating a VM and configuring it. The major difference between it and its predecessor is that new install, boot, and the macOS Base System images are created and then used by the VM for installation.

The original `macos-guest-virtualbox` script would automate the download of the MacOS installer, then populate a VDI with the install files. That process could be modified with the steps done here but this is how I got it working so I wanted to polish it up and push it. 

While researching the issue I found `runMacOSinVirtualBox` and liked the flow of the process so I took a similar approach (`makefile`...) and used some of the code to generate the installer, Base System, and boot images.

Since this approach uses a patched 10.15.3 Base System an additional step of disabling System Integrity Protection is required. The `macos-guest-virtualbox` nvram files are used to disable SIP for the 10.15.3 installation.

***What's up with the `_boot.efi` files?***

For troubleshooting I try to make a copy of any existing boot.efi file found before replacing it so I can try to follow and learn the way the Base System and Installer lays down `boot.efi` files. These files are not used for anything other than my own personal tracking of what's been touched and what hasn't.

There's a shorter path to getting this working but I reached a working version so I decided to clean it up and push it. I'll continue refactoring...

### History

While working through the 10.15.3 boot issue I came up with a solution that mostly automates the process of installing MacOS Catalina 10.15.3. The core of this project is based on [myspaghetti's](https://github.com/myspaghetti) `macos-guest-virtualbox` but also leverages some of [AlexanderWillner's](https://github.com/AlexanderWillner) `runMacOSinVirtualBox` solution. Both of these projects are solid approaches to getting MacOS up on VirtualBox. I really like the automation (and thoroughness) of the `macos-guest-virtualbox` script but I also like the simplicity of `runMacOSinVirtualBox` (or maybe it's just the `makefile`...). 

While I worked through the 10.15.3 boot issue a [workaround was posted on the `macos-guest-virtualbox` project](https://github.com/myspaghetti/macos-guest-virtualbox/issues/134) that does work. I had solved the boot / install issue when the workaround was posted, and solved it a slightly different way, so I decided to clean things up and formalize the project. 

I came at the problem from a different angle and created a new MacOS installer image that contains the older `boot.efi` file injected into both the installer image, MacOS Installer app, and the BaseSystem.dmg within the MacOS Installer app. This helps with automating the setup with fewer reboots and less streaming keys to the VM Terminal. (*Slipstreaming* installers is [nothing new](http://kylefinley.net/slipstream-visual-studio-2008-service-pack-1) to me so this just seemed like the way to handle it...) 

I used bits of `runMacOSinVirtualBox` so I decided to merge things and start building a hybrid solution that autmated as much as possible. The project still needs cleanup and the process could be built back into either original source project if wanted.

Parts of the original `macos-guest-virtualbox.sh` functionality are no longer needed for this approach so I've removed some things (more cleanup is still needed).

## Documentation
Documentation for the `macos-on-virtualbox` script can be viewed by executing the command `make doc`. (This documentation is not up to date which is why it's not included in `make help`).

## iCloud and iMessage connectivity and NVRAM
iCloud, iMessage, and other connected Apple services require a valid device name and serial number, board ID and serial number, and other genuine (or genuine-like) Apple parameters. These can be set in NVRAM by editing the script. See `make doc` for further information.

## Storage size
The script by default assigns a target virtual disk storage size of 40GB, which is populated to about ??GB on the host on initial installation. After the installation is complete, the storage size may be increased. See `make doc` for further information.

## Graphics controller
Selecting VBoxSVGA instead of VBoxVGA for the graphics controller may considerably increase graphics performance. VBoxVGA is assigned by default for compatibility reasons.

## Audio
MacOS may not support any built-in VirtualBox audio controllers. The bootloader [OpenCore](https://github.com/acidanthera/OpenCorePkg/releases) may be able to load open-source audio drivers in VirtualBox, but it tends to hang the virtual machine.

## FileVault
The VirtualBox EFI implementation does not properly load the FileVault full disk encryption password prompt upon boot. The bootloader [OpenCore](https://github.com/acidanthera/OpenCorePkg/releases) may be able to load the password prompt, but it tends to hang the virtual machine.

## Performance and unsupported features
Developing and maintaining VirtualBox or MacOS features is beyond the scope of this project. Some features may behave unexpectedly, such as USB device support, audio support, and other features.

After successfully creating a working MacOS virtual machine, consider importing it into QEMU/KVM so it can run with hardware passthrough at near-native performance. QEMU/KVM requires additional configuration that is beyond the scope of  the script.

## Dependencies
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)≥6.0 with Extension Pack (currently tested with 6.1)
* `Bash`≥4.3 (GNU variant; run on Windows through [Cygwin](https://cygwin.com/install.html) or WSL)
* `coreutils` (GNU variant; install through package manager)
* `gzip`, `unzip`, `wget`, `xxd` (install through package manager)
* `dmg2img` (install through package manager on Linux, MacOS, or WSL; let the script download it automatically on Cygwin)

## ToDo:
* Fix `make clean`
* Check for installer and `boot.efi` files in place
* Download Mojave installer and extract `boot.efi` from it
* Investigate using the Catalina installer downloaded in original `macos-guest-virtualbox` script instead of the regular installer
* More automation
  - `confirm_boot`: should be able to boot and shutdown using VBoxManage
  - `init_install`: should be able to auto-click through the initial Install macOS Catalina screens
  - Automate the Installer screens

## Credits
As stated above this project is a fork, merge, and modification of the following sources:

* https://github.com/myspaghetti/macos-guest-virtualbox
* https://github.com/AlexanderWillner/runMacOSinVirtualBox