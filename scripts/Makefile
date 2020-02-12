SHELL=bash

help:
	@echo "Some available commands:"
	@echo " - all		: Create BaseSystem, Installer, and Boot Images
	@echo " - base		: Create BaseSystem image"
	@echo " - installer	: Create macOS Catalina installer image with 15.3 boot.efi & BaseSystem"
	@echo " - boot		: Create EFI boot disk"

all:
	@bash make-Catalina-BaseSystem.sh
	@bash make-Catalina-Installer.sh
	@bash make-Catalina-Boot.sh
	
base:
	@bash make-Catalina-BaseSystem.sh

installer:
	@bash make-Catalina-Installer.sh

boot:
	@bash make-Catalina-Boot.sh