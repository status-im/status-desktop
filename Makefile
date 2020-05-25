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
	nim_status_client \
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
 NIM_PARAMS := $(NIM_PARAMS) -L:"-framework Foundation -framework Security -framework IOKit -framework CoreServices"
endif

DOTHERSIDE := vendor/DOtherSide/lib/libDOtherSideStatic.a

# Qt5 dirs (we can't indent with tabs here)
QT5_PCFILEDIR := $(shell pkg-config --variable=pcfiledir Qt5Core 2>/dev/null)
QT5_LIBDIR := $(shell pkg-config --variable=libdir Qt5Core 2>/dev/null)
ifeq ($(QT5_PCFILEDIR),)
 ifeq ($(QTDIR),)
  $(error Can't find your Qt5 installation. Please run "$(MAKE) QTDIR=/path/to/your/Qt5/installation/prefix ...")
 else
  ifeq ($(detected_OS), Darwin)
   QT5_PCFILEDIR := $(QTDIR)/clang_64/lib/pkgconfig
   QT5_LIBDIR := $(QTDIR)/clang_64/lib
   # some manually installed Qt5 instances have wrong paths in their *.pc files, so we pass the right one to the linker here
   NIM_PARAMS += --passL:"-F$(QT5_LIBDIR)"
  else
   QT5_PCFILEDIR := $(QTDIR)/gcc_64/lib/pkgconfig
   QT5_LIBDIR := $(QTDIR)/gcc_64/lib
   NIM_PARAMS += --passL:"-L$(QT5_LIBDIR)"
  endif
 endif
endif
export QT5_LIBDIR
# order matters here, due to "-Wl,-as-needed"
NIM_PARAMS += --passL:"$(DOTHERSIDE) $(shell PKG_CONFIG_PATH="$(QT5_PCFILEDIR)" pkg-config --libs Qt5Core Qt5Qml Qt5Gui Qt5Quick Qt5QuickControls2 Qt5Widgets)"

# TODO: control debug/release builds with a Make var
# We need `-d:debug` to get Nim's default stack traces.
NIM_PARAMS += --outdir:./bin -d:debug
# Enable debugging symbols in DOtherSide, in case we need GDB backtraces from it.
CFLAGS += -g
CXXFLAGS += -g

deps: | deps-common

update: | update-common

APPIMAGETOOL := appimagetool-x86_64.AppImage

$(APPIMAGETOOL):
	wget https://github.com/AppImage/AppImageKit/releases/download/continuous/$(APPIMAGETOOL)
	chmod +x $(APPIMAGETOOL)

$(DOTHERSIDE): | deps
	echo -e $(BUILD_MSG) "DOtherSide"
	+ cd vendor/DOtherSide && \
		rm -f CMakeCache.txt && \
		cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_DOCS=OFF -DENABLE_TESTS=OFF -DENABLE_DYNAMIC_LIBS=OFF -DENABLE_STATIC_LIBS=ON . $(HANDLE_OUTPUT) && \
		$(MAKE) VERBOSE=$(V) $(HANDLE_OUTPUT)

STATUSGO := vendor/status-go/build/bin/libstatus.a

$(STATUSGO): | deps
	echo -e $(BUILD_MSG) "status-go"
	+ cd vendor/status-go && \
	  $(MAKE) statusgo-library $(HANDLE_OUTPUT)

nim_status_client: | $(DOTHERSIDE) $(STATUSGO) deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c $(NIM_PARAMS) --passL:"$(STATUSGO)" --passL:"-lm" src/nim_status_client.nim

run:
	LD_LIBRARY_PATH="$(QT5_LIBDIR)" ./bin/nim_status_client

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
	rm -rf $(APPIMAGE) bin/* tmp/dist $(STATUSGO)
	+ $(MAKE) -C vendor/DOtherSide --no-print-directory clean

endif # "variables.mk" was not included
