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

DOTHERSIDE := None
ifeq ($(detected_OS), Darwin)
DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSide.dylib
else
DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSide.so
endif

APPIMAGETOOL := appimagetool-x86_64.AppImage

$(APPIMAGETOOL):
	wget https://github.com/AppImage/AppImageKit/releases/download/continuous/$(APPIMAGETOOL)
	chmod +x $(APPIMAGETOOL)

$(DOTHERSIDE): | deps
	echo -e $(BUILD_MSG) "DOtherSide"
	+ cd vendor/DOtherSide && \
		mkdir -p build && \
		cd build && \
		cmake -DCMAKE_BUILD_TYPE=Release .. $(HANDLE_OUTPUT) && \
		$(MAKE) DOtherSide # IF WE WANT TO USE LIBDOTHERSIDE AS STATIC LIBRARY, USE `$(MAKE) DOtherSideStatic` INSTEAD

STATUSGO := vendor/status-go/build/bin/libstatus.a

$(STATUSGO): | deps
	echo -e $(BUILD_MSG) "status-go"
	+ cd vendor/status-go && \
	  $(MAKE) statusgo-library


SQLCIPHER := vendor/sqlcipher/sqlite3.c
$(SQLCIPHER): | deps
	echo -e $(BUILD_MSG) "sqlcipher"
	+ cd vendor/sqlcipher && \
	  ./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto" && \
		$(MAKE) sqlite3.c

build-linux: $(DOTHERSIDE) $(SQLCIPHER) $(STATUSGO) src/nim_status_client.nim | deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c -d:nimDebugDlOpen -L:$(STATUSGO) -d:ssl	-L:-lm $(NIM_PARAMS) -L:$(DOTHERSIDE) -L:-lcrypto --outdir:./bin src/nim_status_client.nim

build-macos: $(DOTHERSIDE) $(SQLCIPHER) $(STATUSGO) src/nim_status_client.nim | deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c -d:nimDebugDlOpen -L:$(STATUSGO) -d:ssl -L:-lm -L:"-framework Foundation -framework Security -framework IOKit -framework CoreServices" $(NIM_PARAMS) -L:$(DOTHERSIDE) -L:-lcrypto --outdir:./bin src/nim_status_client.nim

run:
	LD_LIBRARY_PATH=vendor/DOtherSide/build/lib ./bin/nim_status_client

APPIMAGE := NimStatusClient-x86_64.AppImage

$(APPIMAGE): $(DEFAULT_TARGET) $(APPIMAGETOOL) nim-status.desktop
	rm -rf tmp/dist
	mkdir -p tmp/dist/usr/bin
	mkdir -p tmp/dist/usr/lib
	mkdir -p tmp/dist/usr/qml

	# General Files
	cp bin/nim_status_client tmp/dist/usr/bin
	cp nim-status.desktop tmp/dist/.
	cp status.svg tmp/dist/status.svg
	cp -R ui tmp/dist/usr/.

	# Libraries
	cp vendor/DOtherSide/build/lib/libDOtherSide* tmp/dist/usr/lib/.

	# QML Plugins due to bug with linuxdeployqt finding qmlimportscanner
	# This list is obtained with qmlimportscanner -rootPath ui/ -importPath /opt/qt/5.12.6/gcc_64/qml/
	mkdir -p tmp/dist/usr/qml/Qt/labs/
	mkdir -p tmp/dist/usr/qml/QtQuick
	cp -R /opt/qt/5.12.6/gcc_64/qml/Qt/labs/platform tmp/dist/usr/qml/Qt/labs/.
	cp -R /opt/qt/5.12.6/gcc_64/qml/QtQuick.2 tmp/dist/usr/qml/.
	cp -R /opt/qt/5.12.6/gcc_64/qml/QtGraphicalEffects tmp/dist/usr/qml/.
	cp -R /opt/qt/5.12.6/gcc_64/qml/QtQuick/{Controls,Controls.2,Extras,Layouts,Templates.2,Window.2} tmp/dist/usr/qml/QtQuick/.

	echo -e $(BUILD_MSG) "AppImage"
	linuxdeployqt tmp/dist/nim-status.desktop -no-translations -no-copy-copyright-files -qmldir=tmp/dist/usr/ui -bundle-non-qt-libs

	rm tmp/dist/AppRun
	cp AppRun tmp/dist/.

	./$(APPIMAGETOOL) tmp/dist

appimage: $(APPIMAGE)

clean: | clean-common
	rm -rf $(APPIMAGE) bin/* vendor/* tmp/dist

endif # "variables.mk" was not included
