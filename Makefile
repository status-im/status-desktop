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
	nix-shell \
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
        statusq-tests \
        run-statusq-tests \
        storybook-build \
        run-storybook \
        run-storybook-tests \
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

nix-shell: export NIX_USER_CONF_FILES := $(PWD)/nix/nix.conf
nix-shell:
	nix-shell

# must be included after the default target
-include $(BUILD_SYSTEM_DIR)/makefiles/targets.mk

# `qmake` path, either passed explicitely, or as found in PATH
# (makes it possible to override with a custom Qt6 install dir)
QMAKE ?= $(shell which qmake)
QSPEC:=$(shell $(QMAKE) -query QMAKE_XSPEC)
ifeq ($(QSPEC),macx-ios-clang)
mkspecs:=ios
else ifeq ($(QSPEC),macx-clang)
mkspecs:=macx
else ifeq ($(QSPEC),win32-msvc)
mkspecs:=win32
else ifeq ($(QSPEC),linux-g++)
mkspecs:=linux
else ifeq ($(QSPEC),android-clang)
mkspecs:=android
endif

host_os:=$(shell uname -s | tr '[:upper:]' '[:lower:]')

ifeq ($(mkspecs),)
	$(error Cannot find your Qt installation. Please make sure to export correct Qt installation binaries path to PATH env)
endif

ifeq ($(mkspecs),macx)
 CFLAGS := -mmacosx-version-min=13.0
 export CFLAGS
 CGO_CFLAGS := -mmacosx-version-min=13.0
 export CGO_CFLAGS
 LIB_EXT := dylib
  # keep in sync with BOTTLE_MACOS_VERSION
 MACOSX_DEPLOYMENT_TARGET := 13.0
 export MACOSX_DEPLOYMENT_TARGET
 PKG_TARGET := pkg-macos
 RUN_TARGET := run-macos
 QT_ARCH ?= $(shell uname -m)
else ifeq ($(mkspecs),win32)
 LIB_EXT := dll
 PKG_TARGET := pkg-windows
 QRCODEGEN_MAKE_PARAMS := CC=gcc
 RUN_TARGET := run-windows
 VCINSTALLDIR ?= C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\\
 export VCINSTALLDIR
else
 LIB_EXT := so
 PKG_TARGET := pkg-linux
 RUN_TARGET := run-linux
endif

check-qt-dir:
ifeq ($(shell $(QMAKE) -v 2>/dev/null),)
	$(error Cannot find your Qt installation. Please make sure to export correct Qt installation binaries path to PATH env)
endif

check-pkg-target-linux:
ifneq ($(mkspecs),linux)
	$(error The pkg-linux target must be run on Linux)
endif

check-pkg-target-macos:
ifneq ($(mkspecs),macx)
	$(error The pkg-macos target must be run on macOS)
endif

check-pkg-target-windows:
ifneq ($(mkspecs),win32)
	$(error The pkg-windows target must be run on Windows)
endif

ifeq ($(mkspecs),macx)
BOTTLES_DIR := $(shell pwd)/bottles
BOTTLES := $(addprefix $(BOTTLES_DIR)/,openssl@3)
ifeq ($(QT_ARCH),arm64)
# keep in sync with MACOSX_DEPLOYMENT_TARGET
	BOTTLE_MACOS_VERSION := 'arm64_ventura'
else
	BOTTLE_MACOS_VERSION := 'ventura'
endif
$(BOTTLES):
	echo -e "\033[92mFetching:\033[39m $(notdir $@) bottle arch $(QT_ARCH) $(BOTTLE_MACOS_VERSION)"
	./scripts/fetch-brew-bottle.sh $(notdir $@) $(BOTTLE_MACOS_VERSION) $(HANDLE_OUTPUT)

bottles: $(BOTTLES)
endif

deps: | check-qt-dir deps-common status-go-deps bottles

update: | check-qt-dir update-common
ifeq ($(mkspecs),macx)
	# Install or update package.json files
	yarn install --check-files
endif

QML_DEBUG ?= false
QML_DEBUG_PORT ?= 49152

ifneq ($(QML_DEBUG), false)
 COMMON_CMAKE_BUILD_TYPE=Debug
 DOTHERSIDE_CMAKE_CONFIG_PARAMS := -DQML_DEBUG_PORT=$(QML_DEBUG_PORT)
else
 COMMON_CMAKE_BUILD_TYPE=Release
endif

MONITORING ?= false
ifneq ($(MONITORING), false)
 DOTHERSIDE_CMAKE_CONFIG_PARAMS += -DMONITORING:BOOL=ON -DMONITORING_QML_ENTRY_POINT:STRING="/../monitoring/Main.qml"
endif

# where Qt is installed, depends on the `QMAKE` path
QT_INSTALL_PREFIX := $(shell $(QMAKE) -query QT_INSTALL_PREFIX 2>/dev/null)
# what Qt version are we building against
QT_VERSION := $(shell $(QMAKE) -query QT_VERSION 2>/dev/null)
# separate DOS build dir, per Qt version
DOTHERSIDE_BUILD_PATH := vendor/DOtherSide/build/Qt$(QT_VERSION)
# separate StatusQ/storybook/... build dirs, per Qt version
COMMON_CMAKE_CONFIG_PARAMS := -DCMAKE_PREFIX_PATH=$(QT_INSTALL_PREFIX)

# Qt dirs (we can't indent with tabs here)
 QT_MAJOR_VERSION := $(shell $(QMAKE) -query QT_VERSION | head -c 1 2>/dev/null)

ifneq ($(QT_MAJOR_VERSION),6)
 $(error Detected Qt major version $(QT_MAJOR_VERSION), but version 6 is required. Please install Qt 6 and set paths accordingly.)
endif

ifneq ($(mkspecs),win32)
 export QT_LIBDIR := $(shell $(QMAKE) -query QT_INSTALL_LIBS 2>/dev/null)
 QT_QMLDIR := $(shell $(QMAKE) -query QT_INSTALL_QML 2>/dev/null)
 QT_INSTALL_PREFIX := $(shell $(QMAKE) -query QT_INSTALL_PREFIX 2>/dev/null)
 QT_PKGCONFIG_INSTALL_PREFIX := $(shell pkg-config --variable=prefix Qt"$(QT_MAJOR_VERSION)"Core 2>/dev/null)
 ifeq ($(QT_INSTALL_PREFIX),$(QT_PKGCONFIG_INSTALL_PREFIX))
  QT_PCFILEDIR := $(shell pkg-config --variable=pcfiledir Qt6Core 2>/dev/null)
 else
  QT_PCFILEDIR := $(QT_LIBDIR)/pkgconfig
 endif
 # some manually installed Qt instances have wrong paths in their *.pc files, so we pass the right one to the linker here
 ifeq ($(mkspecs),macx)
  NIM_PARAMS += -L:"-framework Foundation -framework AppKit -framework Security -framework IOKit -framework CoreServices -framework LocalAuthentication"
  # Fix for failures due to 'can't allocate code signature data for'
  NIM_PARAMS += --passL:"-headerpad_max_install_names"
  NIM_PARAMS += --passL:"-F$(QT_LIBDIR)"

 else
  NIM_PARAMS += --passL:"-L$(QT_LIBDIR)"
 endif
 DOTHERSIDE_LIBFILE := $(DOTHERSIDE_BUILD_PATH)/lib/libDOtherSideStatic.a
 # order matters here, due to "-Wl,-as-needed"
 NIM_PARAMS += --passL:"$(DOTHERSIDE_LIBFILE)" --passL:"$(shell PKG_CONFIG_PATH="$(QT_PCFILEDIR)" pkg-config --libs Qt"$(QT_MAJOR_VERSION)"Core Qt"$(QT_MAJOR_VERSION)"Qml Qt"$(QT_MAJOR_VERSION)"Gui Qt"$(QT_MAJOR_VERSION)"Quick Qt"$(QT_MAJOR_VERSION)"QuickControls2 Qt"$(QT_MAJOR_VERSION)"Widgets Qt"$(QT_MAJOR_VERSION)"Svg Qt"$(QT_MAJOR_VERSION)"Multimedia Qt"$(QT_MAJOR_VERSION)"WebView Qt"$(QT_MAJOR_VERSION)"WebChannel)"
else
 NIM_EXTRA_PARAMS := --passL:"-lsetupapi -lhid"
endif

ifeq ($(mkspecs),win32)
 COMMON_CMAKE_CONFIG_PARAMS += -A x64
endif

ifeq ($(mkspecs),macx)
 ifeq ("$(shell sysctl -nq hw.optional.arm64)","1")
   ifneq ($(QT_ARCH),arm64)
	STATUSGO_MAKE_PARAMS += GOBIN_SHARED_LIB_CFLAGS="CGO_ENABLED=1 GOOS=darwin GOARCH=amd64"
	STATUSKEYCARDGO_MAKE_PARAMS += CGOFLAGS="CGO_ENABLED=1 GOOS=darwin GOARCH=amd64"
	COMMON_CMAKE_CONFIG_PARAMS += -DCMAKE_OSX_ARCHITECTURES=x86_64
	QRCODEGEN_MAKE_PARAMS += CFLAGS="-target x86_64-apple-macos10.12"
	NIM_PARAMS += --cpu:amd64 --os:MacOSX --passL:"-arch x86_64" --passC:"-arch x86_64"
  endif
 endif
endif

ifeq ($(USE_NWAKU), true)
	STATUSGO_MAKE_PARAMS += USE_NWAKU=true
	LIBWAKU := vendor/status-go/vendor/github.com/waku-org/waku-go-bindings/third_party/nwaku/build/libwaku.$(LIB_EXT)
	LIBWAKU_LIBDIR := $(shell pwd)/$(shell dirname "$(LIBWAKU)")
	export LIBWAKU
	NIM_EXTRA_PARAMS +=	--passL:"-L$(LIBWAKU_LIBDIR)" --passL:"-lwaku"
endif

INCLUDE_DEBUG_SYMBOLS ?= false
ifeq ($(INCLUDE_DEBUG_SYMBOLS),true)
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
DESKTOP_VERSION = $(shell ./scripts/version.sh)
STATUSGO_VERSION = $(shell make -C vendor/status-go version -s)
NIM_PARAMS += -d:DESKTOP_VERSION="$(DESKTOP_VERSION)"
NIM_PARAMS += -d:STATUSGO_VERSION="$(STATUSGO_VERSION)"

GIT_COMMIT=`git log --pretty=format:'%h' -n 1`
NIM_PARAMS += -d:GIT_COMMIT="$(GIT_COMMIT)"

OUTPUT_CSV ?= false
ifeq ($(OUTPUT_CSV), true)
  NIM_PARAMS += -d:output_csv
  $(shell touch .update.timestamp)
endif

##
## Versioning
##

version:
	@echo $(DESKTOP_VERSION)

status-go-version:
	@echo $(STATUSGO_VERSION)


##
##	StatusQ
##

STATUSQ_SOURCE_PATH := ui/StatusQ
STATUSQ_BUILD_PATH := ui/StatusQ/build/Qt$(QT_VERSION)
export STATUSQ_INSTALL_PATH := $(shell pwd)/bin
STATUSQ_CMAKE_CACHE := $(STATUSQ_BUILD_PATH)/CMakeCache.txt

$(STATUSQ_CMAKE_CACHE): | check-qt-dir
	echo -e "\033[92mConfiguring:\033[39m StatusQ"
	cmake \
		-DCMAKE_INSTALL_PREFIX=$(STATUSQ_INSTALL_PATH) \
		-DCMAKE_BUILD_TYPE=$(COMMON_CMAKE_BUILD_TYPE) \
		-DSTATUSQ_BUILD_SANDBOX=OFF \
		-DSTATUSQ_BUILD_SANITY_CHECKER=OFF \
		-DSTATUSQ_BUILD_TESTS=OFF \
		$(COMMON_CMAKE_CONFIG_PARAMS) \
		-B $(STATUSQ_BUILD_PATH) \
		-S $(STATUSQ_SOURCE_PATH) \
		-Wno-dev \
		$(HANDLE_OUTPUT)

statusq-configure: | $(STATUSQ_CMAKE_CACHE)

statusq-build: | statusq-configure
	echo -e "\033[92mBuilding:\033[39m StatusQ"
	cmake --build $(STATUSQ_BUILD_PATH) \
		--target StatusQ \
		--config $(COMMON_CMAKE_BUILD_TYPE) \
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
		$(COMMON_CMAKE_CONFIG_PARAMS) \
		-B $(STATUSQ_BUILD_PATH) \
		-S $(STATUSQ_SOURCE_PATH) \
		$(HANDLE_OUTPUT)
	echo -e "\033[92mBuilding:\033[39m StatusQ SanityChecker"
	cmake \
		--build $(STATUSQ_BUILD_PATH) \
		--target SanityChecker \
		$(HANDLE_OUTPUT)

run-statusq-sanity-checker: statusq-sanity-checker
	echo -e "\033[92mRunning:\033[39m StatusQ SanityChecker"
	$(STATUSQ_BUILD_PATH)/bin/SanityChecker

statusq-tests:
	echo -e "\033[92mConfiguring:\033[39m StatusQ Unit Tests"
	cmake \
		-DSTATUSQ_BUILD_SANDBOX=OFF \
		-DSTATUSQ_BUILD_SANITY_CHECKER=OFF \
		-DSTATUSQ_BUILD_TESTS=ON \
		-DSTATUSQ_SHADOW_BUILD=OFF \
		$(COMMON_CMAKE_CONFIG_PARAMS) \
		-B $(STATUSQ_BUILD_PATH) \
		-S $(STATUSQ_SOURCE_PATH) \
		$(HANDLE_OUTPUT)
	echo -e "\033[92mBuilding:\033[39m StatusQ Unit Tests"
	cmake \
		--build $(STATUSQ_BUILD_PATH) \
		$(HANDLE_OUTPUT)

run-statusq-tests: export QTWEBENGINE_CHROMIUM_FLAGS := "${QTWEBENGINE_CHROMIUM_FLAGS} --disable-seccomp-filter-sandbox"
run-statusq-tests: statusq-tests
	echo -e "\033[92mRunning:\033[39m StatusQ Unit Tests"
	ctest -V --test-dir $(STATUSQ_BUILD_PATH) ${ARGS}

##
##	Storybook
##

STORYBOOK_SOURCE_PATH := storybook
STORYBOOK_BUILD_PATH := $(STORYBOOK_SOURCE_PATH)/build/Qt$(QT_VERSION)
STORYBOOK_CMAKE_CACHE := $(STORYBOOK_BUILD_PATH)/CMakeCache.txt

$(STORYBOOK_CMAKE_CACHE): | check-qt-dir
	echo -e "\033[92mConfiguring:\033[39m Storybook"
	cmake \
		-DCMAKE_INSTALL_PREFIX=$(STORYBOOK_INSTALL_PATH) \
		-DCMAKE_BUILD_TYPE=$(COMMON_CMAKE_BUILD_TYPE) \
		-DSTATUSQ_SHADOW_BUILD=OFF \
		$(COMMON_CMAKE_CONFIG_PARAMS) \
		-B $(STORYBOOK_BUILD_PATH) \
		-S $(STORYBOOK_SOURCE_PATH) \
		-Wno-dev \
		$(HANDLE_OUTPUT)

storybook-configure: | $(STORYBOOK_CMAKE_CACHE)

storybook-build: | storybook-configure
	echo -e "\033[92mBuilding:\033[39m Storybook"
	cmake --build $(STORYBOOK_BUILD_PATH) \
		--config $(COMMON_CMAKE_BUILD_TYPE) \
		$(HANDLE_OUTPUT)

run-storybook: storybook-build
	echo -e "\033[92mRunning:\033[39m Storybook"
	$(STORYBOOK_BUILD_PATH)/bin/Storybook ${ARGS}

run-storybook-tests: storybook-build
	echo -e "\033[92mRunning:\033[39m Storybook Tests"
	ctest -V --test-dir $(STORYBOOK_BUILD_PATH) -E PagesValidator

# repeat because of https://bugreports.qt.io/browse/QTBUG-92236 (Qt < 5.15.4)
run-storybook-pages-validator: storybook-build
	echo -e "\033[92mRunning:\033[39m Storybook Pages Validator"
	ctest -V --test-dir $(STORYBOOK_BUILD_PATH) -R PagesValidator --repeat until-pass:3

storybook-clean:
	echo -e "\033[92mCleaning:\033[39m Storybook"
	rm -rf $(STORYBOOK_BUILD_PATH)

##
##	DOtherSide
##

ifneq ($(mkspecs),win32)
 DOTHERSIDE_CMAKE_CONFIG_PARAMS += -DENABLE_DYNAMIC_LIBS=OFF -DENABLE_STATIC_LIBS=ON
#  NIM_PARAMS +=
else
 DOTHERSIDE_LIBFILE := $(DOTHERSIDE_BUILD_PATH)/lib/$(COMMON_CMAKE_BUILD_TYPE)/DOtherSide.dll
 DOTHERSIDE_CMAKE_CONFIG_PARAMS += -DENABLE_DYNAMIC_LIBS=ON -DENABLE_STATIC_LIBS=OFF
 NIM_PARAMS += -L:$(DOTHERSIDE_LIBFILE)
endif

DOTHERSIDE_SOURCE_PATH := vendor/DOtherSide
DOTHERSIDE_CMAKE_CACHE := $(DOTHERSIDE_BUILD_PATH)/CMakeCache.txt
DOTHERSIDE_LIBDIR := $(shell pwd)/$(shell dirname "$(DOTHERSIDE_LIBFILE)")
export DOTHERSIDE_LIBDIR

$(DOTHERSIDE_CMAKE_CACHE): | deps
	echo -e "\033[92mConfiguring:\033[39m DOtherSide"
	cmake \
		-DCMAKE_BUILD_TYPE=$(COMMON_CMAKE_BUILD_TYPE) \
		-DENABLE_DOCS=OFF \
		-DENABLE_TESTS=OFF \
		$(COMMON_CMAKE_CONFIG_PARAMS) \
		$(DOTHERSIDE_CMAKE_CONFIG_PARAMS) \
		-B $(DOTHERSIDE_BUILD_PATH) \
		-S $(DOTHERSIDE_SOURCE_PATH) \
		-Wno-dev \
		$(HANDLE_OUTPUT)

dotherside-configure: | $(DOTHERSIDE_CMAKE_CACHE)

dotherside-build: | dotherside-configure
	echo -e "\033[92mBuilding:\033[39m DOtherSide"
	cmake \
		--build $(DOTHERSIDE_BUILD_PATH) \
		--config $(COMMON_CMAKE_BUILD_TYPE) \
		$(HANDLE_OUTPUT)

dotherside-clean:
	echo -e "\033[92mCleaning:\033[39m DOtherSide"
	rm -rf $(DOTHERSIDE_BUILD_PATH)

dotherside: | dotherside-build

##
##	status-go
##

STATUSGO := vendor/status-go/build/bin/libstatus.$(LIB_EXT)
STATUSGO_LIBDIR := $(shell pwd)/$(shell dirname "$(STATUSGO)")
export STATUSGO_LIBDIR

$(STATUSGO): | deps status-go-deps
	echo -e $(BUILD_MSG) "status-go"
	# FIXME: Nix shell usage breaks builds due to Glibc mismatch.
	$(MAKE) -C vendor/status-go statusgo-shared-library SHELL=/bin/sh \
		SENTRY_CONTEXT_NAME="status-desktop" \
		SENTRY_CONTEXT_VERSION="$(DESKTOP_VERSION)" \
		$(STATUSGO_MAKE_PARAMS) $(HANDLE_OUTPUT)

status-go: $(STATUSGO)

status-go-deps:
	go install go.uber.org/mock/mockgen@v0.4.0
	go install github.com/kevinburke/go-bindata/v4/...@v4.0.2
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.34.1

status-go-clean:
	echo -e "\033[92mCleaning:\033[39m status-go"
	rm -f $(STATUSGO)

export STATUSKEYCARDGO := vendor/status-keycard-go/build/libkeycard/libkeycard.$(LIB_EXT)
export STATUSKEYCARDGO_LIBDIR := "$(shell pwd)/$(shell dirname "$(STATUSKEYCARDGO)")"

status-keycard-go: $(STATUSKEYCARDGO)
$(STATUSKEYCARDGO): | deps
	echo -e $(BUILD_MSG) "status-keycard-go"
	+ $(MAKE) -C vendor/status-keycard-go \
		$(if $(filter 1 true,$(USE_MOCKED_KEYCARD_LIB)), build-mocked-lib, build-lib) \
		$(STATUSKEYCARDGO_MAKE_PARAMS) $(HANDLE_OUTPUT)

QRCODEGEN := vendor/QR-Code-generator/c/libqrcodegen.a

$(QRCODEGEN): | deps
	echo -e $(BUILD_MSG) "QR-Code-generator"
	+ cd vendor/QR-Code-generator/c && \
	  $(MAKE) $(QRCODEGEN_MAKE_PARAMS) $(HANDLE_OUTPUT)

FLEETS_FILE := ./fleets.json
$(FLEETS_FILE):
	echo -e $(BUILD_MSG) "Getting latest $(FLEETS_FILE)"
	curl -s https://fleets.status.im/ > $(FLEETS_FILE)

fleets-remove:
	rm -f $(FLEETS_FILE)

fleets-update: fleets-remove $(FLEETS_FILE)

# When modifying files that are not tracked in UI_SOURCES (see below),
# e.g. ui/shared/img/*.svg, REBUILD_UI=true can be supplied to `make` to ensure
# a rebuild of resources.rcc: `make REBUILD_UI=true run`
REBUILD_UI ?= false

ifeq ($(REBUILD_UI),true)
 $(shell touch ui/main.qml)
endif

ifeq ($(host_os),darwin)
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

# used to override the default number of kdf iterations for sqlcipher
KDF_ITERATIONS ?= 0
ifeq ($(shell test $(KDF_ITERATIONS) -gt 0; echo $$?),0)
  NIM_PARAMS += -d:KDF_ITERATIONS:"$(KDF_ITERATIONS)"
endif

NIM_PARAMS += -d:chronicles_sinks=textlines[stdout],textlines[nocolors,dynamic],textlines[file,nocolors] -d:chronicles_runtime_filtering=on -d:chronicles_default_output_device=dynamic -d:chronicles_log_level=trace

RESOURCES_LAYOUT ?= -d:development

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

STATUS_RC_FILE := status.rc

# Building the resource files for windows to set the icon
compile_windows_resources:
	windres $(STATUS_RC_FILE) -o status.o

ifeq ($(mkspecs),win32)
 NIM_STATUS_CLIENT := bin/nim_status_client.exe
else
 NIM_STATUS_CLIENT := bin/nim_status_client
endif

# Writing the QMAKE variable to a file to compare its value from the previous
# make call and forcing linking of NIM_STATUS_CLIENT if the value has changed.

# Define the file to store the previous QMAKE value
QMAKE_PREVIOUS := .qmake_previous

# Check if the QMAKE value has changed
QMAKE_CHANGED := $(shell [ -f $(QMAKE_PREVIOUS) ] && [ "$$(cat $(QMAKE_PREVIOUS))" = "$(QMAKE)" ] && echo "no" || echo "yes")

# Target to store the current QMAKE value
update-qmake-previous:
	@echo $(QMAKE) > $(QMAKE_PREVIOUS)

# Add a dependency on update-qmake-previous if QMAKE has changed
ifeq ($(QMAKE_CHANGED),yes)
$(NIM_STATUS_CLIENT): update-qmake-previous
endif

$(NIM_STATUS_CLIENT): NIM_PARAMS += $(RESOURCES_LAYOUT)
$(NIM_STATUS_CLIENT): $(NIM_SOURCES) | statusq dotherside check-qt-dir $(STATUSGO) $(STATUSKEYCARDGO) $(QRCODEGEN) $(FLEETS_FILE) rcc compile-translations deps
	echo -e $(BUILD_MSG) "$@"
	$(ENV_SCRIPT) nim c $(NIM_PARAMS) \
		--mm:refc \
		--passL:"-L$(STATUSGO_LIBDIR)" \
		--passL:"-lstatus" \
		--passL:"-L$(STATUSQ_INSTALL_PATH)/StatusQ" \
		--passL:"-lStatusQ" \
		--passL:"-L$(STATUSKEYCARDGO_LIBDIR)" \
		--passL:"-lkeycard" \
		--passL:"$(QRCODEGEN)" \
		--passL:"-lm" \
		--parallelBuild:0 \
		$(NIM_EXTRA_PARAMS) src/nim_status_client.nim
ifeq ($(mkspecs),macx)
	install_name_tool -change \
		libstatus.dylib \
		@rpath/libstatus.dylib \
		bin/nim_status_client
	install_name_tool -change \
		libkeycard.dylib \
		@rpath/libkeycard.dylib \
		bin/nim_status_client
endif

nim_status_client: force-rebuild-status-go statusq dotherside $(NIM_STATUS_CLIENT)

ifdef IN_NIX_SHELL
APPIMAGE_TOOL := appimagetool
else
APPIMAGE_TOOL := tmp/linux/tools/appimagetool
endif

_APPIMAGE_TOOL := appimagetool-x86_64.AppImage
$(APPIMAGE_TOOL):
ifndef IN_NIX_SHELL
	echo -e "\033[92mFetching:\033[39m appimagetool"
	rm -rf tmp/linux
	mkdir -p tmp/linux/tools
	wget -nv https://github.com/AppImage/appimagetool/releases/download/continuous/$(_APPIMAGE_TOOL)
	mv $(_APPIMAGE_TOOL) $(APPIMAGE_TOOL)
	chmod +x $(APPIMAGE_TOOL)
endif

STATUS_CLIENT_APPIMAGE ?= pkg/Status.AppImage
STATUS_CLIENT_TARBALL ?= pkg/Status.tar.gz
STATUS_CLIENT_TARBALL_FULL ?= $(shell realpath $(STATUS_CLIENT_TARBALL))

ifeq ($(mkspecs),linux)
 export FCITX5_QT := vendor/fcitx5-qt/build/qt$(QT_MAJOR_VERSION)/platforminputcontext/libfcitx5platforminputcontextplugin.so
 FCITX5_QT_CMAKE_PARAMS := -DCMAKE_BUILD_TYPE=Release -DBUILD_ONLY_PLUGIN=ON -DENABLE_QT4=OFF
 FCITX5_QT_CMAKE_PARAMS += -DENABLE_QT5=OFF -DENABLE_QT6=ON
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

PRODUCTION_PARAMETERS ?= -d:production

export APP_DIR := tmp/linux/dist

$(STATUS_CLIENT_APPIMAGE): override RESOURCES_LAYOUT := $(PRODUCTION_PARAMETERS)
$(STATUS_CLIENT_APPIMAGE): nim_status_client $(APPIMAGE_TOOL) nim-status.desktop $(FCITX5_QT)
	rm -rf pkg/*.AppImage
	chmod -R u+w tmp || true

	scripts/init_app_dir.sh

	echo -e $(BUILD_MSG) "AppImage"

	linuxdeployqt $(APP_DIR)/nim-status.desktop \
		-no-copy-copyright-files \
		-qmldir=ui -qmlimport=$(QT_QMLDIR) \
		-bundle-non-qt-libs \
		-exclude-libs=libgmodule-2.0.so.0,libgthread-2.0.so.0,libqsqlmimer,libqsqlmysql \
		-verbose=1 \
		-executable=$(APP_DIR)/usr/bin/pcscd \
		-executable=$(APP_DIR)/usr/libexec/QtWebEngineProcess

	scripts/fix_app_dir.sh

	rm $(APP_DIR)/AppRun
	cp AppRun $(APP_DIR)/.

	mkdir -p pkg
	$(APPIMAGE_TOOL) $(APP_DIR) $(STATUS_CLIENT_APPIMAGE)

# Fix rpath and interpreter for AppImage
ifdef IN_NIX_SHELL
	patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 $(STATUS_CLIENT_APPIMAGE)
	patchelf --remove-rpath $(STATUS_CLIENT_APPIMAGE)
endif

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
	yarn install

MACOS_OUTER_BUNDLE := tmp/macos/dist/Status.app
MACOS_INNER_BUNDLE := $(MACOS_OUTER_BUNDLE)/Contents/Frameworks/QtWebEngineCore.framework/Versions/Current/Helpers/QtWebEngineProcess.app

STATUS_CLIENT_DMG ?= pkg/Status.dmg

$(STATUS_CLIENT_DMG): override RESOURCES_LAYOUT := $(PRODUCTION_PARAMETERS)
$(STATUS_CLIENT_DMG): ENTITLEMENTS ?= resources/Entitlements.plist
$(STATUS_CLIENT_DMG): nim_status_client $(DMG_TOOL)
	rm -rf tmp/macos pkg/*.dmg
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/MacOS
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/Resources
	cp Info.plist $(MACOS_OUTER_BUNDLE)/Contents/
	cp bin/nim_status_client $(MACOS_OUTER_BUNDLE)/Contents/MacOS/
	cp status.icns $(MACOS_OUTER_BUNDLE)/Contents/Resources/
	cp status-macos.svg $(MACOS_OUTER_BUNDLE)/Contents/
	cp -R resources.rcc $(MACOS_OUTER_BUNDLE)/Contents/
	mkdir -p $(MACOS_OUTER_BUNDLE)/Contents/i18n
	cp bin/i18n/* $(MACOS_OUTER_BUNDLE)/Contents/i18n

	echo -e $(BUILD_MSG) "app"
	MAC_QTQMLDIR=$(shell $(QMAKE) -query QT_INSTALL_QML) && \
	macdeployqt \
		$(MACOS_OUTER_BUNDLE) \
		-executable=$(MACOS_OUTER_BUNDLE)/Contents/MacOS/nim_status_client \
		-qmldir=ui \
		-qmlimport=$$MAC_QTQMLDIR \
	macdeployqt \
		$(MACOS_INNER_BUNDLE) \
		-executable=$(MACOS_INNER_BUNDLE)/Contents/MacOS/QtWebEngineProcess

	# if MACOS_CODESIGN_IDENT is not set then the outer and inner .app
	# bundles are not signed
ifdef MACOS_CODESIGN_IDENT
	scripts/sign-macos-pkg.sh $(MACOS_OUTER_BUNDLE) $(MACOS_CODESIGN_IDENT) \
		--entitlements $(ENTITLEMENTS)
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

notarize-macos: export CHECK_TIMEOUT ?= 10m
notarize-macos: export MACOS_BUNDLE_ID ?= im.status.ethereum.desktop
notarize-macos:
	scripts/notarize-macos-pkg.sh $(STATUS_CLIENT_DMG)

nim_windows_launcher: | deps
	$(ENV_SCRIPT) nim c -d:debug --outdir:./bin --passL:"-static-libgcc -Wl,-Bstatic,--whole-archive -lwinpthread -Wl,--no-whole-archive" src/nim_windows_launcher.nim

STATUS_CLIENT_EXE ?= pkg/Status.exe
STATUS_CLIENT_7Z ?= pkg/Status.7z

$(STATUS_CLIENT_EXE): override RESOURCES_LAYOUT := $(PRODUCTION_PARAMETERS)
$(STATUS_CLIENT_EXE): OUTPUT := tmp/windows/dist/Status
$(STATUS_CLIENT_EXE): INSTALLER_OUTPUT := pkg
$(STATUS_CLIENT_EXE): compile_windows_resources nim_status_client nim_windows_launcher
	rm -rf pkg/*.exe tmp/windows/dist
	mkdir -p $(OUTPUT)/bin $(OUTPUT)/resources $(OUTPUT)/vendor $(OUTPUT)/resources/i18n
	cat windows-install.txt | unix2dos > $(OUTPUT)/INSTALL.txt
	cp status.ico status.png resources.rcc $(OUTPUT)/resources/
	cp bin/i18n/* $(OUTPUT)/resources/i18n
	cp cacert.pem $(OUTPUT)/bin/cacert.pem
	cp bin/nim_status_client.exe $(OUTPUT)/bin/Status.exe
	cp bin/nim_windows_launcher.exe $(OUTPUT)/Status.exe
	rcedit $(OUTPUT)/bin/Status.exe --set-icon $(OUTPUT)/resources/status.ico
	rcedit $(OUTPUT)/Status.exe --set-icon $(OUTPUT)/resources/status.ico
	cp $(DOTHERSIDE_LIBFILE) $(STATUSGO) $(STATUSKEYCARDGO) $(STATUSQ_INSTALL_PATH)/StatusQ/* $(OUTPUT)/bin/
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
	   -D"Version=$(DESKTOP_VERSION)" \
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

clean-destdir:
	rm -rf bin/*

clean: | clean-common clean-destdir statusq-clean status-go-clean dotherside-clean storybook-clean
	rm -rf node_modules bottles/* pkg/* tmp/* $(STATUSKEYCARDGO)
	+ $(MAKE) -C vendor/QR-Code-generator/c/ --no-print-directory clean

clean-git:
	./scripts/clean-git.sh

force-rebuild-status-go:
	bash ./scripts/force-rebuild-status-go.sh $(STATUSGO)

run: $(RUN_TARGET)

# Will only work at password login. Keycard login doesn't forward the configuration
# STATUS_PORT ?= 30306
# WAKUV2_PORT ?= 30307

run-linux: nim_status_client
	echo -e "\033[92mRunning:\033[39m bin/nim_status_client"
	LD_LIBRARY_PATH="$(QT_LIBDIR)":"$(LIBWAKU_LIBDIR)":"$(STATUSGO_LIBDIR)":"$(STATUSKEYCARDGO_LIBDIR)":"$(STATUSQ_INSTALL_PATH)/StatusQ":"$(LD_LIBRARY_PATH)" \
	./bin/nim_status_client $(ARGS)

run-linux-gdb: nim_status_client
	echo -e "\033[92mRunning:\033[39m bin/nim_status_client"
	LD_LIBRARY_PATH="$(QT_LIBDIR)":"$(LIBWAKU_LIBDIR)":"$(STATUSGO_LIBDIR)":"$(STATUSKEYCARDGO_LIBDIR)":"$(STATUSQ_INSTALL_PATH)/StatusQ":"$(LD_LIBRARY_PATH)" \
	gdb -ex=r ./bin/nim_status_client $(ARGS)

run-macos: nim_status_client
	mkdir -p bin/StatusDev.app/Contents/{MacOS,Resources}
	cp Info.dev.plist bin/StatusDev.app/Contents/Info.plist
	cp status-dev.icns bin/StatusDev.app/Contents/Resources/
	cd bin/StatusDev.app/Contents/MacOS && \
		ln -fs ../../../nim_status_client ./
	fileicon set bin/nim_status_client status-dev.icns
	echo -e "\033[92mRunning:\033[39m bin/StatusDev.app/Contents/MacOS/nim_status_client"
	./bin/StatusDev.app/Contents/MacOS/nim_status_client $(ARGS)

run-windows: STATUS_RC_FILE = status-dev.rc
run-windows: compile_windows_resources nim_status_client
	echo -e "\033[92mRunning:\033[39m bin/nim_status_client.exe"
	PATH="$(DOTHERSIDE_LIBDIR)":"$(STATUSGO_LIBDIR)":"$(STATUSKEYCARDGO_LIBDIR)":"$(STATUSQ_INSTALL_PATH)/StatusQ":"$(PATH)" \
	./bin/nim_status_client.exe $(ARGS)

NIM_TEST_FILES := $(wildcard test/nim/*.nim)
NIM_TESTS := $(foreach test_file,$(NIM_TEST_FILES),nim-test-run/$(test_file))

nim-test-run/%: | dotherside $(STATUSGO) $(QRCODEGEN)
	LD_LIBRARY_PATH="$(QT_LIBDIR)":"$(LIBWAKU_LIBDIR)":"$(STATUSGO_LIBDIR)":"$(LD_LIBRARY_PATH)" $(ENV_SCRIPT) \
	nim c $(NIM_PARAMS) $(NIM_EXTRA_PARAMS) --mm:refc --passL:"-L$(STATUSGO_LIBDIR)" --passL:"-lstatus" --passL:"$(QRCODEGEN)" -r $(subst nim-test-run/,,$@)

tests-nim-linux: $(NIM_TESTS)

define qmkq
$(shell $(QMAKE) -query $(1))
endef

export PATH := $(call qmkq,QT_INSTALL_BINS):$(call qmkq,QT_HOST_BINS):$(call qmkq,QT_HOST_LIBEXECS):$(PATH)
export QTDIR := $(call qmkq,QT_INSTALL_PREFIX)

mobile-run: deps-common
	echo -e "\033[92mRunning:\033[39m mobile app"
	$(MAKE) -C mobile run

mobile-build: | deps-common
	echo -e "\033[92mBuilding:\033[39m mobile app"
	$(MAKE) -C mobile

mobile-clean:
	echo -e "\033[92mCleaning:\033[39m mobile app"
	$(MAKE) -C mobile clean

endif # "variables.mk" was not included
