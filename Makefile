# Copyright (c) 2019-2020 Status Research & Development GmbH. Licensed under
# either of:
# - Apache License, version 2.0
# - MIT license
# at your option. This file may not be copied, modified, or distributed except
# according to those terms.

SHELL := bash # the shell used internally by Make

# used inside the included makefiles
BUILD_SYSTEM_DIR := vendor/nimbus-build-system

# we don't want an error here, so we can handle things later, in the ".DEFAULT" target
-include $(BUILD_SYSTEM_DIR)/makefiles/variables.mk

.PHONY: \
	all \
	appimage \
	clean \
	deps \
	update

ifeq ($(NIM_PARAMS),)
# "variables.mk" was not included, so we update the submodules.
GIT_SUBMODULE_UPDATE := git submodule update --init --recursive
.DEFAULT:
	+@ echo -e "Git submodules not found. Running '$(GIT_SUBMODULE_UPDATE)'.\n"; \
		$(GIT_SUBMODULE_UPDATE); \
		echo
# Now that the included *.mk files appeared, and are newer than this file, Make will restart itself:
# https://www.gnu.org/software/make/manual/make.html#Remaking-Makefiles
#
# After restarting, it will execute its original goal, so we don't have to start a child Make here
# with "$(MAKE) $(MAKECMDGOALS)". Isn't hidden control flow great?

else # "variables.mk" was included. Business as usual until the end of this file.


ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
    detected_OS := Windows
else
    detected_OS := $(strip $(shell uname))
endif


DEFAULT_TARGET := None
ifeq ($(detected_OS), Darwin)
	DEFAULT_TARGET := build-macos
else
	DEFAULT_TARGET := build-linux	
endif

all: $(DEFAULT_TARGET)

# must be included after the default target
-include $(BUILD_SYSTEM_DIR)/makefiles/targets.mk

deps: | deps-common

update: | update-common

DEPLOYQT := linuxdeployqt-continuous-x86_64.AppImage

$(DEPLOYQT):
	wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/$(DEPLOYQT)
	chmod +x $(DEPLOYQT)

DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSideStatic.a

$(DOTHERSIDE): | deps
	echo -e $(BUILD_MSG) "DOtherSide"
	+ cd vendor/DOtherSide && \
		mkdir -p build && \
		cd build && \
		cmake -DCMAKE_BUILD_TYPE=Release .. $(HANDLE_OUTPUT) && \
		$(MAKE) # IF WE WANT TO USE LIBDOTHERSIDE AS STATIC LIBRARY, USE `$(MAKE) DOtherSideStatic` INSTEAD

STATUSGO := vendor/status-go/build/bin/libstatus.a

$(STATUSGO): | deps
	echo -e $(BUILD_MSG) "status-go"
	+ cd vendor/status-go && \
	  $(MAKE) setup-dev && \
	  $(MAKE) statusgo-library

build-linux: $(DOTHERSIDE) $(STATUSGO) src/nim_status_client.nim | deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c -L:$(STATUSGO) -d:ssl -L:-lm -L:-Lvendor/DOtherSide/build/lib/ $(NIM_PARAMS) --outdir:./bin src/nim_status_client.nim

build-macos: $(DOTHERSIDE) $(STATUSGO) src/nim_status_client.nim | deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c -L:$(STATUSGO) -d:ssl -L:-lm -L:"-framework Foundation -framework Security -framework IOKit -framework CoreServices" -L:-Lvendor/DOtherSide/build/lib/ $(NIM_PARAMS) --outdir:./bin src/nim_status_client.nim

APPIMAGE := NimStatusClient-x86_64.AppImage

$(APPIMAGE): $(DEFAULT_TARGET) $(DEPLOYQT) nim-status.desktop
	rm -rf tmp/dist
	mkdir -p tmp/dist/usr/bin
	cp bin/nim_status_client tmp/dist/usr/bin
	cp nim-status.desktop tmp/dist/.
	cp status.svg tmp/dist/status.svg
	cp -R ui tmp/dist/usr/.
	echo -e $(BUILD_MSG) "AppImage"
	./$(DEPLOYQT) tmp/dist/nim-status.desktop -no-translations -no-copy-copyright-files -appimage

appimage: $(APPIMAGE)

clean: | clean-common
	rm -rf $(APPIMAGE) bin/* vendor/DOtherSide/build tmp/dist vendor/status-go/build/bin

endif # "variables.mk" was not included
