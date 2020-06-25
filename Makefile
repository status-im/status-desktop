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
	bottles \
	bottles-dummy \
	bottles-macos \
	clean \
	deps \
	nim_status_client \
	pkg \
	pkg-linux \
	pkg-macos \
	run \
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

all: nim_status_client

# must be included after the default target
-include $(BUILD_SYSTEM_DIR)/makefiles/targets.mk

ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
 detected_OS := Windows
else
 detected_OS := $(strip $(shell uname))
endif

ifeq ($(detected_OS), Darwin)
 BOTTLES_TARGET := bottles-macos
 PKG_TARGET := pkg-macos
 MACOSX_DEPLOYMENT_TARGET := 10.13
 export MACOSX_DEPLOYMENT_TARGET
 CGO_CFLAGS := -mmacosx-version-min=10.13
 export CGO_CFLAGS
 CFLAGS := -mmacosx-version-min=10.13
 export CFLAGS
else
 BOTTLES_TARGET := bottles-dummy
 PKG_TARGET := pkg-linux
endif

bottles: $(BOTTLES_TARGET)

bottles-dummy: ;

BOTTLE_OPENSSL := bottles/openssl/INSTALL_RECEIPT.json

$(BOTTLE_OPENSSL):
	rm -rf bottles/Downloads/openssl* bottles/openssl*
	mkdir -p bottles/Downloads
	cd bottles/Downloads && \
	wget -O openssl.tar.gz "https://bintray.com/homebrew/bottles/download_file?file_path=openssl%401.1-1.1.1g.high_sierra.bottle.tar.gz" && \
	tar xzf openssl* && \
	mv openssl@1.1/1.1.1g ../openssl

BOTTLE_PCRE := bottles/pcre/INSTALL_RECEIPT.json

$(BOTTLE_PCRE):
	rm -rf bottles/Downloads/pcre* bottles/pcre*
	mkdir -p bottles/Downloads
	cd bottles/Downloads && \
	wget -O pcre.tar.gz "https://bintray.com/homebrew/bottles/download_file?file_path=pcre-8.44.high_sierra.bottle.tar.gz" && \
	tar xzf pcre* && \
	mv pcre/8.44 ../pcre

bottles-macos: | $(BOTTLE_OPENSSL) $(BOTTLE_PCRE)
	rm -rf bottles/Downloads

ifeq ($(detected_OS), Darwin)
 NIM_PARAMS := $(NIM_PARAMS) -L:"-framework Foundation -framework Security -framework IOKit -framework CoreServices"
endif

DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSideStatic.a

# Qt5 dirs (we can't indent with tabs here)
QT5_PCFILEDIR := $(shell pkg-config --variable=pcfiledir Qt5Core 2>/dev/null)
QT5_LIBDIR := $(shell pkg-config --variable=libdir Qt5Core 2>/dev/null)
ifeq ($(QT5_PCFILEDIR),)
 ifeq ($(QTDIR),)
  $(error Can't find your Qt5 installation. Please run "$(MAKE) QTDIR=/path/to/your/Qt5/installation/prefix ...")
 else
  ifeq ($(detected_OS), Darwin)
   QT5_PCFILEDIR := $(QTDIR)/lib/pkgconfig
   QT5_LIBDIR := $(QTDIR)/lib
   # some manually installed Qt5 instances have wrong paths in their *.pc files, so we pass the right one to the linker here
   NIM_PARAMS += --passL:"-F$(QT5_LIBDIR)"
  else
   QT5_PCFILEDIR := $(QTDIR)/lib/pkgconfig
   QT5_LIBDIR := $(QTDIR)/lib
   NIM_PARAMS += --passL:"-L$(QT5_LIBDIR)"
  endif
 endif
endif
export QT5_LIBDIR
# order matters here, due to "-Wl,-as-needed"
NIM_PARAMS += --passL:"$(DOTHERSIDE) $(shell PKG_CONFIG_PATH="$(QT5_PCFILEDIR)" pkg-config --libs Qt5Core Qt5Qml Qt5Gui Qt5Quick Qt5QuickControls2 Qt5Widgets Qt5Svg)"

# TODO: control debug/release builds with a Make var
# We need `-d:debug` to get Nim's default stack traces.
NIM_PARAMS += --outdir:./bin -d:debug
# Enable debugging symbols in DOtherSide, in case we need GDB backtraces from it.
CFLAGS += -g
CXXFLAGS += -g

deps: | deps-common bottles

update: | update-common

$(DOTHERSIDE): | deps
	echo -e $(BUILD_MSG) "DOtherSide"
	+ cd vendor/DOtherSide && \
		mkdir -p build && \
		cd build && \
		rm -f CMakeCache.txt && \
		cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_DOCS=OFF -DENABLE_TESTS=OFF -DENABLE_DYNAMIC_LIBS=OFF -DENABLE_STATIC_LIBS=ON .. $(HANDLE_OUTPUT) && \
		$(MAKE) VERBOSE=$(V) $(HANDLE_OUTPUT)

STATUSGO := vendor/status-go/build/bin/libstatus.a

$(STATUSGO): | deps
	echo -e $(BUILD_MSG) "status-go"
	+ cd vendor/status-go && \
	  $(MAKE) statusgo-library $(HANDLE_OUTPUT)

QRCODEGEN := vendor/QR-Code-generator/c/libqrcodegen.a

$(QRCODEGEN): | deps
	echo -e $(BUILD_MSG) "QR-Code-generator"
	+ cd vendor/QR-Code-generator/c && \
	  $(MAKE)

nim_status_client: | $(DOTHERSIDE) $(STATUSGO) $(QRCODEGEN) deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c $(NIM_PARAMS) --passL:"$(STATUSGO)" --passL:"$(QRCODEGEN)" --passL:"-lm" src/nim_status_client.nim

_APPIMAGE_TOOL := appimagetool-x86_64.AppImage
APPIMAGE_TOOL := tmp/linux/tools/$(_APPIMAGE_TOOL)

$(APPIMAGE_TOOL):
	rm -rf tmp/linux
	mkdir -p tmp/linux/tools
	wget https://github.com/AppImage/AppImageKit/releases/download/continuous/$(_APPIMAGE_TOOL)
	mv $(_APPIMAGE_TOOL) tmp/linux/tools/
	chmod +x $(APPIMAGE_TOOL)

APPIMAGE := pkg/NimStatusClient-x86_64.AppImage

$(APPIMAGE): nim_status_client $(APPIMAGE_TOOL) nim-status.desktop
	rm -rf pkg/*.AppImage
	mkdir -p tmp/linux/dist/usr/bin
	mkdir -p tmp/linux/dist/usr/lib
	mkdir -p tmp/linux/dist/usr/qml

	# General Files
	cp bin/nim_status_client tmp/linux/dist/usr/bin
	cp nim-status.desktop tmp/linux/dist/.
	cp status.svg tmp/linux/dist/status.svg
	cp -R ui tmp/linux/dist/usr/.

	echo -e $(BUILD_MSG) "AppImage"
	linuxdeployqt tmp/linux/dist/nim-status.desktop -no-translations -no-copy-copyright-files -qmldir=tmp/linux/dist/usr/ui -qmlimport=$(QTDIR)/qml -bundle-non-qt-libs

	rm tmp/linux/dist/AppRun
	cp AppRun tmp/linux/dist/.

	mkdir -p pkg
	$(APPIMAGE_TOOL) tmp/linux/dist $(APPIMAGE)

DMG_TOOL := node_modules/.bin/create-dmg

$(DMG_TOOL):
	npm i

MACOS_OUTER_BUNDLE := tmp/macos/dist/Status.app
MACOS_INNER_BUNDLE := $(MACOS_OUTER_BUNDLE)/Contents/Frameworks/QtWebEngineCore.framework/Versions/Current/Helpers/QtWebEngineProcess.app

DMG := pkg/Status.dmg

# it's not required to set MACOS_KEYCHAIN if MACOS_CODESIGN_IDENT can be found
# in e.g. your login keychain; this environment variable is primarily useful
# for CI; when specified MACOS_KEYCHAIN should be the path to a preferred
# keychain database file
ifneq ($(MACOS_KEYCHAIN),)
 MACOS_KEYCHAIN_OPT := --keychain "$(MACOS_KEYCHAIN)"
endif

$(DMG): nim_status_client $(DMG_TOOL)
	rm -rf tmp/macos pkg/*.dmg
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/MacOS
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/Resources
	cp Info.plist $(MACOS_OUTER_BUNDLE)/Contents/
	cp bin/nim_status_client $(MACOS_OUTER_BUNDLE)/Contents/MacOS/
	cp nim_status_client.sh $(MACOS_OUTER_BUNDLE)/Contents/MacOS/
	chmod +x $(MACOS_OUTER_BUNDLE)/Contents/MacOS/nim_status_client.sh
	cp status-icon.icns $(MACOS_OUTER_BUNDLE)/Contents/Resources/
	cp -R ui $(MACOS_OUTER_BUNDLE)/Contents/

	macdeployqt \
		$(MACOS_OUTER_BUNDLE) \
		-executable=$(MACOS_OUTER_BUNDLE)/Contents/MacOS/nim_status_client \
		-qmldir=ui
	cp Info.runner.plist $(MACOS_OUTER_BUNDLE)/Contents/Info.plist
	macdeployqt \
		$(MACOS_INNER_BUNDLE) \
		-executable=$(MACOS_INNER_BUNDLE)/Contents/MacOS/QtWebEngineProcess

	# if MACOS_CODESIGN_IDENT is not set then the outer and inner .app
	# bundles are not signed
	[ -z "$(MACOS_CODESIGN_IDENT)" ] || \
		codesign \
			--sign "$(MACOS_CODESIGN_IDENT)" \
			$(MACOS_KEYCHAIN_OPT) \
			--options runtime \
			--deep \
			--force \
			--verbose=4 \
			$(MACOS_OUTER_BUNDLE)
	[ -z "$(MACOS_CODESIGN_IDENT)" ] || \
		codesign \
			--sign "$(MACOS_CODESIGN_IDENT)" \
			$(MACOS_KEYCHAIN_OPT) \
			--entitlements QtWebEngineProcess.plist \
			--options runtime \
			--deep \
			--force \
			--verbose=4 \
			$(MACOS_INNER_BUNDLE)

	mkdir -p pkg
	# See: https://github.com/sindresorhus/create-dmg#dmg-icon
	# GraphicsMagick must be installed for create-dmg to make the custom
	# DMG icon based on app icon, but should otherwise work without it
	npx create-dmg \
		--identity="NOBODY" \
		$(MACOS_OUTER_BUNDLE) \
		pkg || true
	# `|| true` is used above because code signing will be done manually
	# below (to allow for MACOS_KEYCHAIN_OPT) but create-dmg doesn't have
	# an option to not attempt signing. To work around that limitation an
	# unlikely identity (NOBODY) is specified; this results in a non-zero
	# exit code even though the .dmg is created successfully (just not code
	# signed); if the above command failed to create a .dmg then the
	# following command should result in a non-zero exit code
	mv "`ls pkg/*.dmg`" pkg/Status.dmg

	# if MACOS_CODESIGN_IDENT is not set then the .dmg is not signed
	[ -z "$(MACOS_CODESIGN_IDENT)" ] || \
		codesign \
			--sign "$(MACOS_CODESIGN_IDENT)" \
			$(MACOS_KEYCHAIN_OPT) \
			--verbose=4 \
			pkg/Status.dmg

pkg: $(PKG_TARGET)

pkg-linux: $(APPIMAGE)

pkg-macos: $(DMG)

clean: | clean-common
	rm -rf bin/* node_modules pkg/* tmp/* $(STATUSGO)
	+ $(MAKE) -C vendor/DOtherSide/build --no-print-directory clean

run:
	LD_LIBRARY_PATH="$(QT5_LIBDIR)" ./bin/nim_status_client

endif # "variables.mk" was not included
