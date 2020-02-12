SCRIPT=./macos-on-virtualbox.sh

SHELL=bash

help:
	@echo "Steps to install Catalina: make COMMAND"
	@echo "   COMMAND	  Description"
	@echo " - catalina	: Create VM & disks, partition HD, init installer, fix startup, run installer, fix Preboot, and start Catalina"
	@echo " - delete	: Delete exiting vm"
	@echo " - clean	: Delete temporary files (currently busted...)"

doc:
	@bash  $(SCRIPT) documentation

catalina:
	make set
	make check
	make create_vm
	make boot_files
	make prepare
	make nvram_files
	make base
	sudo make installer
	make boot
	make hd
	make configure_vm
	make confirm_boot
	@echo "Power off the machine and press enter to continue"
	@bash read
	make set_disks
	@echo "When VM shuts down press enter to continue"
	@bash read
	make init_install
	@echo "Power off the machine and press enter to continue"
	@bash read
	make fix_init
	@echo "When VM shuts down press enter to continue"
	@bash read
	make start_install
	@echo "Power off the machine and press enter to continue"
	@bash read
	make fix_preboot
	@echo "When VM shuts down press enter to continue"
	@bash read
	@echo "Booting MacOS Catalina 10.15.3!"
	make start

start:
	@bash  $(SCRIPT) start_catalina

check:
	@bash  $(SCRIPT) check_bash_version

set:
	@bash  $(SCRIPT) set_variables

base:
	@bash ./scripts/make-Catalina-BaseSystem.sh

installer:
	@bash ./scripts/make-Catalina-Installer.sh

boot:
	@bash ./scripts/make-Catalina-Boot.sh
	
confirm_boot:
	@bash  $(SCRIPT) confirm_boot

init_install:
	@bash  $(SCRIPT) init_installer
	
start_install:
	@bash  $(SCRIPT) start_installer

fix_init:
	@bash  $(SCRIPT) fix_init_installer

fix_preboot:
	@bash  $(SCRIPT) fix_preboot

welcome:
	@bash  $(SCRIPT) welcome

check_dependencies:
	@bash  $(SCRIPT) check_dependencies

delete:
	@bash  $(SCRIPT) prompt_delete_existing_vm

create_vm:
	@bash  $(SCRIPT) create_vm

nvram_files:
	@bash  $(SCRIPT) create_nvram_files
	
boot_files:
	@bash  $(SCRIPT) create_macos_installation_files_viso

prepare:
	@bash  $(SCRIPT) prepare_macos_installation_files
	
hd:
	@bash  $(SCRIPT) create_target_vdi

create_install_vdi:
	@bash  $(SCRIPT) create_install_vdi
	
configure_vm:
	@bash  $(SCRIPT) configure_vm

set_disks:
	@bash  $(SCRIPT) populate_virtual_disks

clean:
	@bash  $(SCRIPT) delete_temporary_files

