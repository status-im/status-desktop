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
	build \
	clean \
	deps \
	pkg \
	pkg-linux \
	pkg-macos \
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

build: $(DEFAULT_TARGET)

PKG_TARGET := None
ifeq ($(detected_OS), Darwin)
	PKG_TARGET := pkg-macos
else
	PKG_TARGET := pkg-linux
endif

all: $(PKG_TARGET)

# must be included after the default target
-include $(BUILD_SYSTEM_DIR)/makefiles/targets.mk

deps: | deps-common

update: | update-common

DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSideStatic.a

$(DOTHERSIDE): | deps
	echo -e $(BUILD_MSG) "DOtherSide"
	+ cd vendor/DOtherSide && \
		mkdir -p build && \
		cd build && \
		cmake -DCMAKE_BUILD_TYPE=Release .. $(HANDLE_OUTPUT) && \
		$(MAKE) DOtherSideStatic

STATUSGO := vendor/status-go/build/bin/libstatus.a

$(STATUSGO): | deps
	echo -e $(BUILD_MSG) "status-go"
	+ cd vendor/status-go && \
	  $(MAKE) statusgo-library

build-linux: $(DOTHERSIDE) $(STATUSGO) src/nim_status_client.nim | deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c \
			-d:ssl \
			-L:-lm \
			-L:$(DOTHERSIDE) \
			-L:$(STATUSGO) \
			$(NIM_PARAMS) \
			--outdir:./bin \
			src/nim_status_client.nim

build-macos: $(DOTHERSIDE) $(STATUSGO) src/nim_status_client.nim | deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c \
			-d:ssl \
			--passL="-F$(QTDIR)/clang_64/lib" \
			--passL="-rpath $(QTDIR)/clang_64/lib" \
			-L:-lm \
			-L:-lstdc++ \
			-L:$(DOTHERSIDE) \
			-L:$(STATUSGO) \
			-L:"-framework CoreServices" \
			-L:"-framework Foundation" \
			-L:"-framework IOKit" \
			-L:"-framework Security" \
			-L:"-framework QtCore" \
			-L:"-framework QtGui" \
			-L:"-framework QtNetwork" \
			-L:"-framework QtQml" \
			-L:"-framework QtQmlModels" \
			-L:"-framework QtQuick" \
			-L:"-framework QtQuickControls2" \
			-L:"-framework QtSvg" \
			-L:"-framework QtWidgets" \
			$(NIM_PARAMS) \
			--outdir:./bin \
			src/nim_status_client.nim

_APPIMAGETOOL := appimagetool-x86_64.AppImage
APPIMAGETOOL := tmp/linux/tools/$(_APPIMAGETOOL)

$(APPIMAGETOOL):
	mkdir -p tmp/linux/tools
	cd tmp/linux/tools && \
	wget https://github.com/AppImage/AppImageKit/releases/download/continuous/$(_APPIMAGETOOL)
	chmod +x $(APPIMAGETOOL)

APPIMAGE := pkg/NimStatusClient-x86_64.AppImage

$(APPIMAGE): $(DEFAULT_TARGET) $(APPIMAGETOOL) nim-status.desktop
	rm -rf tmp/linux pkg/*.AppImage
	mkdir -p tmp/linux/dist/usr/bin
	mkdir -p tmp/linux/dist/usr/lib
	mkdir -p tmp/linux/dist/usr/qml

	# General Files
	cp bin/nim_status_client tmp/linux/dist/usr/bin
	cp nim-status.desktop tmp/linux/dist/.
	cp status.svg tmp/linux/dist/status.svg
	cp -R ui tmp/linux/dist/usr/.

	# Libraries
	cp vendor/DOtherSide/build/lib/libDOtherSide* tmp/linux/dist/usr/lib/.

	# QML Plugins due to bug with linuxdeployqt finding qmlimportscanner
	# This list is obtained with qmlimportscanner -rootPath ui/ -importPath /opt/qt/5.12.6/gcc_64/qml/
	mkdir -p tmp/linux/dist/usr/qml/Qt/labs/
	mkdir -p tmp/linux/dist/usr/qml/QtQuick
	cp -R /opt/qt/5.12.6/gcc_64/qml/Qt/labs/platform tmp/linux/dist/usr/qml/Qt/labs/.
	cp -R /opt/qt/5.12.6/gcc_64/qml/QtQuick.2 tmp/linux/dist/usr/qml/.
	cp -R /opt/qt/5.12.6/gcc_64/qml/QtGraphicalEffects tmp/linux/dist/usr/qml/.
	cp -R /opt/qt/5.12.6/gcc_64/qml/QtQuick/{Controls,Controls.2,Extras,Layouts,Templates.2,Window.2} tmp/linux/dist/usr/qml/QtQuick/.

	echo -e $(BUILD_MSG) "AppImage"
	linuxdeployqt tmp/linux/dist/nim-status.desktop -no-translations -no-copy-copyright-files -qmldir=tmp/linux/dist/usr/ui -bundle-non-qt-libs

	rm tmp/linux/dist/AppRun
	cp AppRun tmp/linux/dist/.

	# should $(APPIMAGE) on the right below be just pkg/ ?
	$(APPIMAGETOOL) tmp/linux/dist $(APPIMAGE)

CREATEDMGTOOL := node_modules/.bin/create-dmg

$(CREATEDMGTOOL):
	npm i

DMG := pkg/Status.dmg

# See: https://github.com/sindresorhus/create-dmg#dmg-icon
# need to have GraphicsMagick installed for create-dmg to create the custom
# DMG icon based on app icon, but should work without it
$(DMG): $(DEFAULT_TARGET) $(CREATEDMGTOOL)
	rm -rf tmp/macos pkg/*.dmg
	mkdir -p tmp/macos/dist/Status.app/Contents/MacOS
	mkdir -p tmp/macos/dist/Status.app/Contents/Resources

	cp Info.plist tmp/macos/dist/Status.app/Contents/
	cp bin/nim_status_client tmp/macos/dist/Status.app/Contents/MacOS/
	cp nim_status_client.sh tmp/macos/dist/Status.app/Contents/MacOS/
	chmod +x tmp/macos/dist/Status.app/Contents/MacOS/nim_status_client.sh
	cp status-icon.icns tmp/macos/dist/Status.app/Contents/Resources/
	cp -R ui tmp/macos/dist/Status.app/Contents/
	macdeployqt tmp/macos/dist/Status.app -qmldir=ui
	cp Info.runner.plist tmp/macos/dist/Status.app/Contents/Info.plist
	mkdir -p pkg
	npx create-dmg tmp/macos/dist/Status.app pkg || true
	mv "`ls pkg/*.dmg`" pkg/Status.dmg

# `|| true` is used above because if code signing isn't setup then running
# `npx create-dmg` results in a non-zero exit code even though the .dmg is
# created successfully (just not code signed)

pkg: $(PKG_TARGET)

pkg-linux: $(APPIMAGE)

pkg-macos: $(DMG)

clean: | clean-common
	rm -rf bin/* node_modules/* pkg/* tmp/* vendor/*

run: $(DEFAULT_TARGET)
	bin/nim_status_client

endif # "variables.mk" was not included
