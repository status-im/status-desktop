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
	check-qt-dir \
	check-pkg-target-linux \
	check-pkg-target-macos \
	check-pkg-target-windows \
	clean \
	compile-translations \
	deps \
	fleets-remove \
	fleets-update \
	nim_status_client \
	nim_windows_launcher \
	pkg \
	pkg-linux \
	pkg-macos \
	pkg-windows \
	run \
	run-linux \
	run-macos \
	run-windows \
	tests-nim-linux \
	status-go \
	status-keycard-go \
	statusq-sanity-checker \
	run-statusq-sanity-checker \
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

ifeq ($(detected_OS),Darwin)
 CFLAGS := -mmacosx-version-min=10.14
 export CFLAGS
 CGO_CFLAGS := -mmacosx-version-min=10.14
 export CGO_CFLAGS
 LIBSTATUS_EXT := dylib
 MACOSX_DEPLOYMENT_TARGET := 10.14
 export MACOSX_DEPLOYMENT_TARGET
 PKG_TARGET := pkg-macos
 RUN_TARGET := run-macos
 QMAKE_PATH := $(shell which qmake);
 QT_ARCH := $(shell lipo -archs $(QMAKE_PATH))
else ifeq ($(detected_OS),Windows)
 LIBSTATUS_EXT := dll
 PKG_TARGET := pkg-windows
 QRCODEGEN_MAKE_PARAMS := CC=gcc
 RUN_TARGET := run-windows
 VCINSTALLDIR ?= C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\\
 export VCINSTALLDIR
else
 LIBSTATUS_EXT := so
 PKG_TARGET := pkg-linux
 RUN_TARGET := run-linux
endif


check-qt-dir:
ifeq ($(shell qmake -v 2>/dev/null),)
	$(error Cannot find your Qt5 installation. Please make sure to export correct Qt installation binaries path to PATH env)
endif

check-pkg-target-linux:
ifneq ($(detected_OS),Linux)
	$(error The pkg-linux target must be run on Linux)
endif

check-pkg-target-macos:
ifneq ($(detected_OS),Darwin)
	$(error The pkg-macos target must be run on macOS)
endif

check-pkg-target-windows:
ifneq ($(detected_OS),Windows)
	$(error The pkg-windows target must be run on Windows)
endif

ifeq ($(detected_OS),Darwin)
BOTTLES_DIR := $(shell pwd)/bottles
BOTTLES := $(addprefix $(BOTTLES_DIR)/,openssl@1.1 pcre)
ifeq ($(QT_ARCH),arm64)
	EXCLUDE_BOTTLES := 'linux'
else
	EXCLUDE_BOTTLES := 'arm|linux'
endif
$(BOTTLES): | $(BOTTLES_DIR)
	echo -e "\033[92mFetching:\033[39m $(notdir $@) bottle arch $(QT_ARCH)"
	./scripts/fetch-brew-bottle.sh $(notdir $@) $(EXCLUDE_BOTTLES)

$(BOTTLES_DIR):
	echo -e "\033[92mUpdating:\033[39m macOS Homebrew"
	if [[ $$(stat -f %u /usr/local/var/homebrew) -ne "$${UID}" ]]; then \
		echo "Missing permissions to update Homebrew formulae!" >&2; \
	else \
		brew update >/dev/null; \
		mkdir -p $(BOTTLES_DIR); \
	fi

bottles: $(BOTTLES)
endif

deps: | check-qt-dir deps-common bottles

update: | check-qt-dir update-common

QML_DEBUG ?= false
QML_DEBUG_PORT ?= 49152

ifneq ($(QML_DEBUG), false)
 DOTHERSIDE_CMAKE_PARAMS := -DCMAKE_BUILD_TYPE=Debug -DQML_DEBUG_PORT=$(QML_DEBUG_PORT)
 DOTHERSIDE_BUILD_CMD := cmake --build . --config Debug
else
 DOTHERSIDE_CMAKE_PARAMS := -DCMAKE_BUILD_TYPE=Release
 DOTHERSIDE_BUILD_CMD := cmake --build . --config Release
endif

MONITORING ?= false
ifneq ($(MONITORING), false)
 DOTHERSIDE_CMAKE_PARAMS += -DMONITORING:BOOL=ON -DMONITORING_QML_ENTRY_POINT:STRING="/../monitoring/Main.qml"
endif


# Qt5 dirs (we can't indent with tabs here)
ifneq ($(detected_OS),Windows)
 export QT5_LIBDIR := $(shell qmake -query QT_INSTALL_LIBS 2>/dev/null)
 QT5_QMLDIR := $(shell qmake -query QT_INSTALL_QML 2>/dev/null)
 QT5_INSTALL_PREFIX := $(shell qmake -query QT_INSTALL_PREFIX 2>/dev/null)
 QT5_PKGCONFIG_INSTALL_PREFIX := $(shell pkg-config --variable=prefix Qt5Core 2>/dev/null)
 ifeq ($(QT5_INSTALL_PREFIX),$(QT5_PKGCONFIG_INSTALL_PREFIX))
  QT5_PCFILEDIR := $(shell pkg-config --variable=pcfiledir Qt5Core 2>/dev/null)
 else
  QT5_PCFILEDIR := $(QT5_LIBDIR)/pkgconfig
 endif
 # some manually installed Qt5 instances have wrong paths in their *.pc files, so we pass the right one to the linker here
 ifeq ($(detected_OS),Darwin)
  NIM_PARAMS += -L:"-framework Foundation -framework AppKit -framework Security -framework IOKit -framework CoreServices -framework LocalAuthentication"
  # Fix for failures due to 'can't allocate code signature data for'
  NIM_PARAMS += --passL:"-headerpad_max_install_names"
  NIM_PARAMS += --passL:"-F$(QT5_LIBDIR)"

 else
  NIM_PARAMS += --passL:"-L$(QT5_LIBDIR)"
 endif
 DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSideStatic.a
 DOTHERSIDE_CMAKE_PARAMS += -DENABLE_DYNAMIC_LIBS=OFF -DENABLE_STATIC_LIBS=ON
 # order matters here, due to "-Wl,-as-needed"
 NIM_PARAMS += --passL:"$(DOTHERSIDE)" --passL:"$(shell PKG_CONFIG_PATH="$(QT5_PCFILEDIR)" pkg-config --libs Qt5Core Qt5Qml Qt5Gui Qt5Quick Qt5QuickControls2 Qt5Widgets Qt5Svg Qt5Multimedia)"
else
 ifneq ($(QML_DEBUG), false)
  DOTHERSIDE := vendor/DOtherSide/build/lib/Debug/DOtherSide.dll
 else
  DOTHERSIDE := vendor/DOtherSide/build/lib/Release/DOtherSide.dll
 endif
 DOTHERSIDE_CMAKE_PARAMS += -T"v141" -A x64 -DENABLE_DYNAMIC_LIBS=ON -DENABLE_STATIC_LIBS=OFF
 NIM_PARAMS += -L:$(DOTHERSIDE)
 NIM_EXTRA_PARAMS := --passL:"-lsetupapi -lhid"
endif

ifeq ($(detected_OS),Darwin)
 ifeq ("$(shell sysctl -nq hw.optional.arm64)","1")
   ifneq ($(QT_ARCH),arm64)
	STATUSGO_MAKE_PARAMS += GOBIN_SHARED_LIB_CFLAGS="CGO_ENABLED=1 GOOS=darwin GOARCH=amd64"
	STATUSKEYCARDGO_MAKE_PARAMS += CGOFLAGS="CGO_ENABLED=1 GOOS=darwin GOARCH=amd64"
	DOTHERSIDE_CMAKE_PARAMS += -DCMAKE_OSX_ARCHITECTURES=x86_64
	STATUSQ_CMAKE_CONFIG_PARAMS += -DCMAKE_OSX_ARCHITECTURES=x86_64
	QRCODEGEN_MAKE_PARAMS += CFLAGS="-target x86_64-apple-macos10.12"
	NIM_PARAMS += --cpu:amd64 --os:MacOSX --passL:"-arch x86_64" --passC:"-arch x86_64"
  endif
 endif
endif

RELEASE ?= false
ifeq ($(RELEASE),false)
 # We need `-d:debug` to get Nim's default stack traces
 NIM_PARAMS += -d:debug
 # Enable debugging symbols in DOtherSide, in case we need GDB backtraces
 CFLAGS += -g
 CXXFLAGS += -g
 RCC_PARAMS = --no-compress
else
 # Additional optimization flags for release builds are not included at present;
 # adding them will involve refactoring config.nims in the root of this repo
 NIM_PARAMS += -d:release
 STATUSGO_MAKE_PARAMS += CGO_CFLAGS="-O3"
 STATUSKEYCARDGO_MAKE_PARAMS += CGO_CFLAGS="-O3"
endif

NIM_PARAMS += --outdir:./bin

# App version
VERSIONFILE=VERSION
DESKTOP_VERSION=`cat $(VERSIONFILE)`
NIM_PARAMS += -d:DESKTOP_VERSION="$(DESKTOP_VERSION)"

GIT_COMMIT=`git log --pretty=format:'%h' -n 1`
NIM_PARAMS += -d:GIT_COMMIT="$(GIT_COMMIT)"

OUTPUT_CSV ?= false
ifeq ($(OUTPUT_CSV), true)
  NIM_PARAMS += -d:output_csv
  $(shell touch .update.timestamp)
endif


##
##	StatusQ
##

ifneq ($(detected_OS),Windows)
 STATUSQ := bin/StatusQ/libStatusQ.$(LIBSTATUS_EXT)
else
 STATUSQ := bin/StatusQ/StatusQ.$(LIBSTATUS_EXT)
 STATUSQ_CMAKE_CONFIG_PARAMS := -T"v141" -A x64
endif

STATUSQ_BUILD_PATH := ui/StatusQ/build
STATUSQ_INSTALL_PATH := $(shell pwd)/bin
STATUSQ_CMAKE_CACHE := $(STATUSQ_BUILD_PATH)/CMakeCache.txt

$(STATUSQ_CMAKE_CACHE): | deps
	echo -e "\033[92mConfiguring:\033[39m StatusQ"
	cmake -DCMAKE_INSTALL_PREFIX=$(STATUSQ_INSTALL_PATH) \
		-DCMAKE_BUILD_TYPE=Release \
		-DSTATUSQ_BUILD_SANDBOX=OFF \
		-DSTATUSQ_BUILD_SANITY_CHECKER=OFF \
		-DSTATUSQ_BUILD_TESTS=OFF \
		$(STATUSQ_CMAKE_CONFIG_PARAMS) \
		-B $(STATUSQ_BUILD_PATH) \
		-S ui/StatusQ \
		-Wno-dev \
		$(HANDLE_OUTPUT)

statusq-configure: | $(STATUSQ_CMAKE_CACHE) 

statusq-build: | statusq-configure
	echo -e "\033[92mBuilding:\033[39m StatusQ"
	cmake --build $(STATUSQ_BUILD_PATH) \
		--target StatusQ \
		--config Release \
		$(HANDLE_OUTPUT)

statusq-install: | statusq-build
	echo -e "\033[92mInstalling:\033[39m StatusQ"
	cmake --install $(STATUSQ_BUILD_PATH) \
		$(HANDLE_OUTPUT)

statusq: | statusq-install

statusq-clean:
	echo -e "\033[92mCleaning:\033[39m StatusQ"
	rm -rf $(STATUSQ_BUILD_PATH)
	rm -rf $(STATUSQ_INSTALL_PATH)/StatusQ

statusq-sanity-checker:
	echo -e "\033[92mConfiguring:\033[39m StatusQ SanityChecker"
	cmake \
		-DSTATUSQ_BUILD_SANDBOX=OFF \
		-DSTATUSQ_BUILD_SANITY_CHECKER=ON \
		-DSTATUSQ_BUILD_TESTS=OFF \
		-B$(STATUSQ_BUILD_PATH) \
		-Sui/StatusQ \
		$(HANDLE_OUTPUT)
	echo -e "\033[92mBuilding:\033[39m StatusQ SanityChecker"
	cmake \
		--build $(STATUSQ_BUILD_PATH) \
		--target SanityChecker \
		$(HANDLE_OUTPUT)

run-statusq-sanity-checker: statusq-sanity-checker
	echo -e "\033[92mRunning:\033[39m StatusQ SanityChecker"
	$(STATUSQ_BUILD_PATH)/bin/SanityChecker

##
##	DOtherSide
##

$(DOTHERSIDE): | deps
	echo -e $(BUILD_MSG) "DOtherSide"
	+ cd vendor/DOtherSide && \
		mkdir -p build && \
		cd build && \
		rm -f CMakeCache.txt && \
		cmake $(DOTHERSIDE_CMAKE_PARAMS)\
			-DENABLE_DOCS=OFF \
			-DENABLE_TESTS=OFF \
			.. $(HANDLE_OUTPUT) && \
		$(DOTHERSIDE_BUILD_CMD) \
			$(HANDLE_OUTPUT)

dotherside: $(DOTHERSIDE)

dotherside-clean:
	$(MAKE) -C vendor/DOtherSide/build --no-print-directory clean

STATUSGO := vendor/status-go/build/bin/libstatus.$(LIBSTATUS_EXT)
STATUSGO_LIBDIR := $(shell pwd)/$(shell dirname "$(STATUSGO)")
export STATUSGO_LIBDIR

$(STATUSGO): | deps
	echo -e $(BUILD_MSG) "status-go"
	+ cd vendor/status-go && \
	  $(MAKE) statusgo-shared-library $(STATUSGO_MAKE_PARAMS) $(HANDLE_OUTPUT)

status-go: $(STATUSGO)

status-go-clean:
	echo -e "\033[92mCleaning:\033[39m status-go"
	rm -f $(STATUSGO)

STATUSKEYCARDGO := vendor/status-keycard-go/build/libkeycard/libkeycard.$(LIBSTATUS_EXT)
STATUSKEYCARDGO_LIBDIR := $(shell pwd)/$(shell dirname "$(STATUSKEYCARDGO)")
export STATUSKEYCARDGO_LIBDIR

status-keycard-go: $(STATUSKEYCARDGO)
$(STATUSKEYCARDGO): | deps
	echo -e $(BUILD_MSG) "status-keycard-go"
	+ cd vendor/status-keycard-go && \
	  $(MAKE) build-lib $(STATUSKEYCARDGO_MAKE_PARAMS) $(HANDLE_OUTPUT)

QRCODEGEN := vendor/QR-Code-generator/c/libqrcodegen.a

$(QRCODEGEN): | deps
	echo -e $(BUILD_MSG) "QR-Code-generator"
	+ cd vendor/QR-Code-generator/c && \
	  $(MAKE) $(QRCODEGEN_MAKE_PARAMS) $(HANDLE_OUTPUT)

FLEETS := fleets.json
$(FLEETS):
	echo -e $(BUILD_MSG) "Getting latest $(FLEETS)"
	curl -s https://fleets.status.im/ \
		| jq --indent 4 --sort-keys . \
		> $(FLEETS)

fleets-remove:
	rm -f $(FLEETS)

fleets-update: fleets-remove $(FLEETS)

# When modifying files that are not tracked in UI_SOURCES (see below),
# e.g. ui/shared/img/*.svg, REBUILD_UI=true can be supplied to `make` to ensure
# a rebuild of resources.rcc: `make REBUILD_UI=true run`
REBUILD_UI ?= false

ifeq ($(REBUILD_UI),true)
 $(shell touch ui/main.qml)
endif

ifeq ($(detected_OS),Darwin)
 UI_SOURCES := $(shell find -E ui -type f -iregex '.*(qmldir|qml|qrc)$$' -not -iname 'resources.qrc')
else
 UI_SOURCES := $(shell find ui -type f -regextype egrep -iregex '.*(qmldir|qml|qrc)$$' -not -iname 'resources.qrc')
endif

UI_RESOURCES := resources.rcc

$(UI_RESOURCES): $(UI_SOURCES) | check-qt-dir
	echo -e $(BUILD_MSG) "resources.rcc"
	rm -f ./resources.rcc
	rm -f ./ui/resources.qrc
	go run ui/generate-rcc.go -source=ui -output=ui/resources.qrc
	rcc -binary $(RCC_PARAMS) ui/resources.qrc -o ./resources.rcc

rcc: $(UI_RESOURCES)

TS_SOURCES := $(shell find ui/i18n -iname '*.ts') # ui/i18n/qml_*.ts
QM_BINARIES := $(shell find ui/i18n -iname "*.ts" | sed 's/\.ts/\.qm/' | sed 's/ui/bin/') # bin/i18n/qml_*.qm

$(QM_BINARIES): TS_FILE = $(shell echo $@ | sed 's/\.qm/\.ts/' | sed 's/bin/ui/')
$(QM_BINARIES): $(TS_SOURCES) | check-qt-dir
	mkdir -p bin/i18n
	lrelease -removeidentical $(TS_FILE) -qm $@ $(HANDLE_OUTPUT)

log-compile-translations:
	echo -e "\033[92mCompiling:\033[39m translations"

compile-translations: | log-compile-translations $(QM_BINARIES)

# default token is a free-tier token with limited capabilities and usage
# limits; our docs should include directions for community contributor to setup
# their own Pokt account and token instead of relying on this default token
# during development
DEFAULT_POKT_TOKEN := 849214fd2f85acead08f5184
POKT_TOKEN ?= $(DEFAULT_POKT_TOKEN)
NIM_PARAMS += -d:POKT_TOKEN:"$(POKT_TOKEN)"

# default token is a free-tier token with limited capabilities and usage
# limits; our docs should include directions for community contributor to setup
# their own Infura account and token instead of relying on this default token
# during development
DEFAULT_INFURA_TOKEN := 220a1abb4b6943a093c35d0ce4fb0732
INFURA_TOKEN ?= $(DEFAULT_INFURA_TOKEN)
NIM_PARAMS += -d:INFURA_TOKEN:"$(INFURA_TOKEN)"

DEFAULT_OPENSEA_API_KEY := ""
OPENSEA_API_KEY ?= $(DEFAULT_OPENSEA_API_KEY)
NIM_PARAMS += -d:OPENSEA_API_KEY:"$(OPENSEA_API_KEY)"

DEFAULT_TENOR_API_KEY := DU7DWZ27STB2
TENOR_API_KEY ?= $(DEFAULT_TENOR_API_KEY)
NIM_PARAMS += -d:TENOR_API_KEY:"$(TENOR_API_KEY)"

# used to override the default number of kdf iterations for sqlcipher
KDF_ITERATIONS ?= 0
ifeq ($(shell test $(KDF_ITERATIONS) -gt 0; echo $$?),0)
  NIM_PARAMS += -d:KDF_ITERATIONS:"$(KDF_ITERATIONS)"
endif

NIM_PARAMS += -d:chronicles_sinks=textlines[stdout],textlines[nocolors,dynamic],textlines[file,nocolors] -d:chronicles_runtime_filtering=on -d:chronicles_default_output_device=dynamic

RESOURCES_LAYOUT := -d:development

# When modifying files that are not tracked in NIM_SOURCES (see below),
# e.g. vendor/*.nim, REBUILD_NIM=true can be supplied to `make` to ensure a
# rebuild of bin/nim_status_client: `make REBUILD_NIM=true run`
# Note: it is not necessary to supply REBUILD_NIM=true after `make update`
# because that target bumps .update.timestamp
REBUILD_NIM ?= false

ifeq ($(REBUILD_NIM),true)
 $(shell touch .update.timestamp)
endif

.update.timestamp:
	touch .update.timestamp

NIM_SOURCES := .update.timestamp $(shell find src -type f)

ifeq ($(detected_OS),Windows)
 NIM_STATUS_CLIENT := bin/nim_status_client.exe
else
 NIM_STATUS_CLIENT := bin/nim_status_client
endif

$(NIM_STATUS_CLIENT): NIM_PARAMS += $(RESOURCES_LAYOUT)
$(NIM_STATUS_CLIENT): $(NIM_SOURCES) $(DOTHERSIDE) | statusq check-qt-dir $(STATUSGO) $(STATUSKEYCARDGO) $(QRCODEGEN) $(FLEETS) rcc compile-translations deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c $(NIM_PARAMS) --passL:"-L$(STATUSGO_LIBDIR)" --passL:"-lstatus" --passL:"-L$(STATUSKEYCARDGO_LIBDIR)" --passL:"-lkeycard" $(NIM_EXTRA_PARAMS) --passL:"$(QRCODEGEN)" --passL:"-lm" src/nim_status_client.nim && \
		[[ $$? = 0 ]] && \
		(([[ $(detected_OS) = Darwin ]] && \
		install_name_tool -change \
			libstatus.dylib \
			@rpath/libstatus.dylib \
			bin/nim_status_client && \
		install_name_tool -change \
			libkeycard.dylib \
			@rpath/libkeycard.dylib \
			bin/nim_status_client) || true)
ifeq ($(detected_OS),Darwin)
ifeq ("$(wildcard ./node_modules/.bin/fileicon)","")
	echo -e "\033[92mInstalling:\033[39m fileicon"
	npm i
endif
endif

nim_status_client: force-rebuild-status-go $(NIM_STATUS_CLIENT)

_APPIMAGE_TOOL := appimagetool-x86_64.AppImage
APPIMAGE_TOOL := tmp/linux/tools/$(_APPIMAGE_TOOL)

$(APPIMAGE_TOOL):
	echo -e "\033[92mFetching:\033[39m appimagetool"
	rm -rf tmp/linux
	mkdir -p tmp/linux/tools
	wget -nv https://github.com/AppImage/AppImageKit/releases/download/continuous/$(_APPIMAGE_TOOL)
	mv $(_APPIMAGE_TOOL) tmp/linux/tools/
	chmod +x $(APPIMAGE_TOOL)

STATUS_CLIENT_APPIMAGE ?= pkg/Status.AppImage
STATUS_CLIENT_TARBALL ?= pkg/Status.tar.gz
STATUS_CLIENT_TARBALL_FULL ?= $(shell realpath $(STATUS_CLIENT_TARBALL))

ifeq ($(detected_OS),Linux)
 FCITX5_QT := vendor/fcitx5-qt/build/qt5/platforminputcontext/libfcitx5platforminputcontextplugin.so
 FCITX5_QT_CMAKE_PARAMS := -DCMAKE_BUILD_TYPE=Release -DBUILD_ONLY_PLUGIN=ON -DENABLE_QT4=OFF -DENABLE_QT5=ON
 FCITX5_QT_BUILD_CMD := cmake --build . --config Release $(HANDLE_OUTPUT)
endif

$(FCITX5_QT): | check-qt-dir deps
	echo -e $(BUILD_MSG) "fcitx5-qt"
	+ cd vendor/fcitx5-qt && \
		mkdir -p build && \
		cd build && \
		rm -f CMakeCache.txt && \
		cmake $(FCITX5_QT_CMAKE_PARAMS) \
			.. $(HANDLE_OUTPUT) && \
		$(FCITX5_QT_BUILD_CMD)

PRODUCTION_PARAMETERS := -d:production

$(STATUS_CLIENT_APPIMAGE): override RESOURCES_LAYOUT := $(PRODUCTION_PARAMETERS)
$(STATUS_CLIENT_APPIMAGE): nim_status_client $(APPIMAGE_TOOL) nim-status.desktop $(FCITX5_QT)
	rm -rf pkg/*.AppImage
	rm -rf tmp/linux/dist
	mkdir -p tmp/linux/dist/usr/bin
	mkdir -p tmp/linux/dist/usr/lib
	mkdir -p tmp/linux/dist/usr/qml

	# General Files
	cp bin/nim_status_client tmp/linux/dist/usr/bin
	mkdir -p tmp/linux/dist/usr/bin/dictionaries
	cp -R spellchecking/dictionaries tmp/linux/dist/usr/bin/dictionaries
	cp nim-status.desktop tmp/linux/dist/.
	cp status.svg tmp/linux/dist/status.svg
	cp status.svg tmp/linux/dist/usr/.
	cp -R resources.rcc tmp/linux/dist/usr/.
	cp -R $(FLEETS) tmp/linux/dist/usr/.
	mkdir -p tmp/linux/dist/usr/i18n
	cp bin/i18n/* tmp/linux/dist/usr/i18n
	mkdir -p tmp/linux/dist/usr/bin/StatusQ
	cp bin/StatusQ/* tmp/linux/dist/usr/bin/StatusQ

	# Libraries
	cp -r /usr/lib/x86_64-linux-gnu/nss tmp/linux/dist/usr/lib/
	cp -P /usr/lib/x86_64-linux-gnu/libgst* tmp/linux/dist/usr/lib/
	cp -r /usr/lib/x86_64-linux-gnu/gstreamer-1.0 tmp/linux/dist/usr/lib/
	cp -r /usr/lib/x86_64-linux-gnu/gstreamer1.0 tmp/linux/dist/usr/lib/
	cp vendor/status-go/build/bin/libstatus.so tmp/linux/dist/usr/lib/
	cp vendor/status-go/build/bin/libstatus.so.0 tmp/linux/dist/usr/lib/
	cp $(STATUSKEYCARDGO) tmp/linux/dist/usr/lib/

	echo -e $(BUILD_MSG) "AppImage"
	linuxdeployqt tmp/linux/dist/nim-status.desktop -no-copy-copyright-files -qmldir=ui -qmlimport=$(QT5_QMLDIR) -bundle-non-qt-libs

	# Qt plugins
	cp $(FCITX5_QT) tmp/linux/dist/usr/plugins/platforminputcontexts/

	rm tmp/linux/dist/AppRun
	cp AppRun tmp/linux/dist/.

	mkdir -p pkg
	$(APPIMAGE_TOOL) tmp/linux/dist $(STATUS_CLIENT_APPIMAGE)
# if LINUX_GPG_PRIVATE_KEY_FILE is not set then we don't generate a signature
ifdef LINUX_GPG_PRIVATE_KEY_FILE
	scripts/sign-linux-file.sh $(STATUS_CLIENT_APPIMAGE)
endif

$(STATUS_CLIENT_TARBALL): $(STATUS_CLIENT_APPIMAGE)
	cd $(shell dirname $(STATUS_CLIENT_APPIMAGE)) && \
	tar czvf $(STATUS_CLIENT_TARBALL_FULL) --ignore-failed-read \
		$(shell basename $(STATUS_CLIENT_APPIMAGE)){,.asc}
ifdef LINUX_GPG_PRIVATE_KEY_FILE
	scripts/sign-linux-file.sh $(STATUS_CLIENT_TARBALL)
endif

DMG_TOOL := node_modules/.bin/create-dmg

$(DMG_TOOL):
	echo -e "\033[92mInstalling:\033[39m create-dmg"
	npm i

MACOS_OUTER_BUNDLE := tmp/macos/dist/Status.app
MACOS_INNER_BUNDLE := $(MACOS_OUTER_BUNDLE)/Contents/Frameworks/QtWebEngineCore.framework/Versions/Current/Helpers/QtWebEngineProcess.app

STATUS_CLIENT_DMG ?= pkg/Status.dmg

$(STATUS_CLIENT_DMG): override RESOURCES_LAYOUT := $(PRODUCTION_PARAMETERS)
$(STATUS_CLIENT_DMG): nim_status_client $(DMG_TOOL)
	rm -rf tmp/macos pkg/*.dmg
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/MacOS
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/Resources
	cp Info.plist $(MACOS_OUTER_BUNDLE)/Contents/
	cp bin/nim_status_client $(MACOS_OUTER_BUNDLE)/Contents/MacOS/
	cp -R spellchecking/dictionaries $(MACOS_OUTER_BUNDLE)/Contents/MacOS/dictionaries
	cp status.icns $(MACOS_OUTER_BUNDLE)/Contents/Resources/
	cp status-macos.svg $(MACOS_OUTER_BUNDLE)/Contents/
	cp -R resources.rcc $(MACOS_OUTER_BUNDLE)/Contents/
	cp -R $(FLEETS) $(MACOS_OUTER_BUNDLE)/Contents/
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/i18n
	cp bin/i18n/* $(MACOS_OUTER_BUNDLE)/Contents/i18n
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/MacOS/StatusQ
	cp bin/StatusQ/* $(MACOS_OUTER_BUNDLE)/Contents/MacOS/StatusQ

	echo -e $(BUILD_MSG) "app"
	macdeployqt \
		$(MACOS_OUTER_BUNDLE) \
		-executable=$(MACOS_OUTER_BUNDLE)/Contents/MacOS/nim_status_client \
		-qmldir=ui
	macdeployqt \
		$(MACOS_INNER_BUNDLE) \
		-executable=$(MACOS_INNER_BUNDLE)/Contents/MacOS/QtWebEngineProcess

	# if MACOS_CODESIGN_IDENT is not set then the outer and inner .app
	# bundles are not signed
ifdef MACOS_CODESIGN_IDENT
	scripts/sign-macos-pkg.sh $(MACOS_OUTER_BUNDLE) $(MACOS_CODESIGN_IDENT)
	scripts/sign-macos-pkg.sh $(MACOS_INNER_BUNDLE) $(MACOS_CODESIGN_IDENT) \
		--entitlements QtWebEngineProcess.plist
endif
	echo -e $(BUILD_MSG) "dmg"
	mkdir -p pkg
	# See: https://github.com/sindresorhus/create-dmg#dmg-icon
	# GraphicsMagick must be installed for create-dmg to make the custom
	# DMG icon based on app icon, but should otherwise work without it
	npx create-dmg \
		--identity="NOBODY" \
		$(MACOS_OUTER_BUNDLE) \
		pkg || true
	# We ignore failure above create-dmg can't skip signing.
	# To work around that a dummy identity - 'NOBODY' - is specified.
	# This causes non-zero exit code despite DMG being created.
	# It is just not signed, hence the next command should succeed.
	mv "`ls pkg/*.dmg`" $(STATUS_CLIENT_DMG)

ifdef MACOS_CODESIGN_IDENT
	scripts/sign-macos-pkg.sh $(STATUS_CLIENT_DMG) $(MACOS_CODESIGN_IDENT)
endif

notarize-macos: export CHECK_INTERVAL_SEC ?= 30
notarize-macos: export CHECK_RETRY_LIMIT ?= 40
notarize-macos: export MACOS_BUNDLE_ID ?= im.status.ethereum.desktop
notarize-macos:
	scripts/notarize-macos-pkg.sh $(STATUS_CLIENT_DMG)

NIM_WINDOWS_PREBUILT_DLLS ?= tmp/windows/tools/pcre.dll

$(NIM_WINDOWS_PREBUILT_DLLS):
	echo -e "\033[92mFetching:\033[39m prebuilt DLLs from nim-lang.org"
	rm -rf tmp/windows
	mkdir -p tmp/windows/tools
	cd tmp/windows/tools && \
	wget -nv https://nim-lang.org/download/dlls.zip && \
	unzip dlls.zip

nim_windows_launcher: | deps
	$(ENV_SCRIPT) nim c -d:debug --outdir:./bin --passL:"-static-libgcc -Wl,-Bstatic,--whole-archive -lwinpthread -Wl,--no-whole-archive" src/nim_windows_launcher.nim

STATUS_CLIENT_EXE ?= pkg/Status.exe
STATUS_CLIENT_7Z ?= pkg/Status.7z

$(STATUS_CLIENT_EXE): override RESOURCES_LAYOUT := $(PRODUCTION_PARAMETERS)
$(STATUS_CLIENT_EXE): OUTPUT := tmp/windows/dist/Status
$(STATUS_CLIENT_EXE): INSTALLER_OUTPUT := pkg
$(STATUS_CLIENT_EXE): nim_status_client nim_windows_launcher $(NIM_WINDOWS_PREBUILT_DLLS)
	rm -rf pkg/*.exe tmp/windows/dist
	mkdir -p $(OUTPUT)/bin $(OUTPUT)/resources $(OUTPUT)/vendor $(OUTPUT)/resources/i18n $(OUTPUT)/bin/StatusQ
	cat windows-install.txt | unix2dos > $(OUTPUT)/INSTALL.txt
	cp status.ico status.svg resources.rcc $(FLEETS) $(OUTPUT)/resources/
	cp bin/i18n/* $(OUTPUT)/resources/i18n
	cp cacert.pem $(OUTPUT)/bin/cacert.pem
	cp bin/StatusQ/* $(OUTPUT)/bin/StatusQ
	cp bin/nim_status_client.exe $(OUTPUT)/bin/Status.exe
	cp bin/nim_windows_launcher.exe $(OUTPUT)/Status.exe
	rcedit $(OUTPUT)/bin/Status.exe --set-icon $(OUTPUT)/resources/status.ico
	rcedit $(OUTPUT)/Status.exe --set-icon $(OUTPUT)/resources/status.ico
	cp $(DOTHERSIDE) $(STATUSGO) $(STATUSKEYCARDGO) tmp/windows/tools/*.dll $(OUTPUT)/bin/
	cp "$(shell which libgcc_s_seh-1.dll)" $(OUTPUT)/bin/
	cp "$(shell which libwinpthread-1.dll)" $(OUTPUT)/bin/
	echo -e $(BUILD_MSG) "deployable folder"
	windeployqt --compiler-runtime --qmldir ui --release \
		tmp/windows/dist/Status/bin/DOtherSide.dll
	mv tmp/windows/dist/Status/bin/vc_redist.x64.exe tmp/windows/dist/Status/vendor/
	cp status.iss $(OUTPUT)/status.iss
# if WINDOWS_CODESIGN_PFX_PATH is not set then DLLs, EXEs are not signed
ifdef WINDOWS_CODESIGN_PFX_PATH
	scripts/sign-windows-bin.sh ./tmp/windows/dist/Status
endif
	echo -e $(BUILD_MSG) "exe"
	mkdir -p $(INSTALLER_OUTPUT)
	ISCC \
	   -O"$(INSTALLER_OUTPUT)" \
	   -D"BaseName=$(shell basename $(STATUS_CLIENT_EXE) .exe)" \
	   -D"Version=$(shell cat VERSION)" \
	   $(OUTPUT)/status.iss
ifdef WINDOWS_CODESIGN_PFX_PATH
	scripts/sign-windows-bin.sh $(INSTALLER_OUTPUT)
endif

$(STATUS_CLIENT_7Z): OUTPUT := tmp/windows/dist/Status
$(STATUS_CLIENT_7Z): $(STATUS_CLIENT_EXE)
	echo -e $(BUILD_MSG) "7z"
	7z a $(STATUS_CLIENT_7Z) ./$(OUTPUT)

# pkg target rebuilds status client
# this is to ensure production version of the app is deployed
pkg:
	rm $(NIM_STATUS_CLIENT) | :
	$(MAKE) $(PKG_TARGET)

pkg-linux: check-pkg-target-linux $(STATUS_CLIENT_APPIMAGE)

tgz-linux: $(STATUS_CLIENT_TARBALL)

pkg-macos: check-pkg-target-macos $(STATUS_CLIENT_DMG)

pkg-windows: check-pkg-target-windows $(STATUS_CLIENT_EXE)

zip-windows: check-pkg-target-windows $(STATUS_CLIENT_7Z)

clean: | clean-common statusq-clean status-go-clean dotherside-clean
	rm -rf bin/* node_modules bottles/* pkg/* tmp/* $(STATUSKEYCARDGO)
	+ $(MAKE) -C vendor/QR-Code-generator/c/ --no-print-directory clean

clean-git:
	./scripts/clean-git.sh

force-rebuild-status-go:
	bash ./scripts/force-rebuild-status-go.sh $(STATUSGO)

run: $(RUN_TARGET)

ICON_TOOL := node_modules/.bin/fileicon

# Will only work at password login. Keycard login doesn't forward the configuration
# STATUS_PORT ?= 30306
# WAKUV2_PORT ?= 30307

run-linux: nim_status_client
	echo -e "\033[92mRunning:\033[39m bin/nim_status_client"
	LD_LIBRARY_PATH="$(QT5_LIBDIR)":"$(STATUSGO_LIBDIR)":"$(STATUSKEYCARDGO_LIBDIR)" \
	./bin/nim_status_client

run-macos: nim_status_client
	mkdir -p bin/StatusDev.app/Contents/{MacOS,Resources}
	cp Info.dev.plist bin/StatusDev.app/Contents/Info.plist
	cp status-dev.icns bin/StatusDev.app/Contents/Resources/
	cd bin/StatusDev.app/Contents/MacOS && \
		ln -fs ../../../nim_status_client ./
	./node_modules/.bin/fileicon set bin/nim_status_client status-dev.icns
	echo -e "\033[92mRunning:\033[39m bin/StatusDev.app/Contents/MacOS/nim_status_client"
	./bin/StatusDev.app/Contents/MacOS/nim_status_client

run-windows: nim_status_client $(NIM_WINDOWS_PREBUILT_DLLS)
	echo -e "\033[92mRunning:\033[39m bin/nim_status_client.exe"
	PATH="$(shell pwd)"/"$(shell dirname "$(DOTHERSIDE)")":"$(STATUSGO_LIBDIR)":"$(STATUSKEYCARDGO_LIBDIR)":"$(shell pwd)"/"$(shell dirname "$(NIM_WINDOWS_PREBUILT_DLLS)")":"$(PATH)" \
	./bin/nim_status_client.exe

tests-nim-linux: | $(DOTHERSIDE)
	LD_LIBRARY_PATH="$(QT5_LIBDIR)" \
	$(ENV_SCRIPT) nim c $(NIM_PARAMS) $(NIM_EXTRA_PARAMS) -r test/nim/message_model_test.nim

endif # "variables.mk" was not included
