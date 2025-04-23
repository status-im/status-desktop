ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
HOST_ENV=$(shell printenv)

# verbosity level
V := 0
ifeq ($(V), 0)
  HANDLE_OUTPUT := >/dev/null 2>&1
endif

-include $(ROOT_DIR)/scripts/EnvVariables.mk
$(info Configuring build system for $(OS) $(ARCH) with QT $(QT_VERSION))

# path macros
BIN_PATH := $(ROOT_DIR)bin/$(OS)/qt$(QT_VERSION)
LIB_PATH := $(ROOT_DIR)lib/$(OS)/qt$(QT_VERSION)
BUILD_PATH := $(ROOT_DIR)build/$(OS)/qt$(QT_VERSION)
SCRIPTS_PATH := $(ROOT_DIR)scripts

export LIB_DIR=$(LIB_PATH)

WRAPPER_APP?=$(PWD)/wrapperApp
STATUS_DESKTOP?=$(PWD)/vendors/status-desktop
STATUSQ?=$(STATUS_DESKTOP)/ui/StatusQ
STATUS_GO?=$(STATUS_DESKTOP)/vendor/status-go
DOTHERSIDE?=$(STATUS_DESKTOP)/vendor/DOtherSide
OPENSSL?=$(PWD)/vendors/OpenSSL-for-iPhone
QRCODEGEN?=$(STATUS_DESKTOP)/vendor/QR-Code-generator/c
PCRE?=$(PWD)/vendors/pcre-8.45

project_name := Status-tablet

# compile macros
TARGET_NAME := Status-tablet.$(shell if [ $(OS) = "ios" ]; then echo "app"; else echo "apk"; fi )

TARGET := $(BIN_PATH)/$(TARGET_NAME)

# src files & obj files
STATUS_DESKTOP_NIM_FILES := $(shell find $(STATUS_DESKTOP)/src -type f \( -iname '*.nim' -o -iname '*.nims' \))
STATUS_DESKTOP_UI_FILES := $(shell find $(STATUS_DESKTOP)/ui -type f \( -iname 'qmldir' -o -iname '*.qml' -o -iname '*.qrc' \) -not -iname 'resources.qrc' -not -path '$(STATUS_DESKTOP)/ui/StatusQ/*')
STATUS_Q_FILES := $(shell find $(STATUSQ) -type f \( -iname '*.cpp' -o -iname '*.h' \) -not -iname '*.qrc' -not -iname '*.qml')
STATUS_Q_UI_FILES := $(shell find $(STATUSQ) -type f \( -iname '*.qml' -o -iname '*.qrc' \))
STATUS_GO_FILES := $(shell find $(STATUS_GO) -type f)
STATUS_GO_SCRIPT := $(SCRIPTS_PATH)/buildStatusGo.sh
DOTHERSIDE_FILES := $(shell find $(DOTHERSIDE) -type f \( -iname '*.cpp' -o -iname '*.h' \))
OPENSSL_FILES := $(shell find $(OPENSSL)/OpenSSL-for-iOS -type f)
QRCODEGEN_FILES := $(shell find $(QRCODEGEN) -type f \( -iname '*.c' -o -iname '*.h' \))
PCRE_FILES := $(eval $(call findFiles,$(PCRE)))
WRAPPER_APP_FILES := $(eval $(call findFiles,$(WRAPPER_APP)))
COMPAT_QRC_FILE := $(WRAPPER_APP)/compat_resources.qrc
DUMMY_QML_FILE := $(WRAPPER_APP)/DummyCompatImports.qml

# script files
STATUS_Q_SCRIPT := $(SCRIPTS_PATH)/buildStatusQ.sh
STATUS_GO_SCRIPT := $(SCRIPTS_PATH)/buildStatusGo.sh
DOTHERSIDE_SCRIPT := $(SCRIPTS_PATH)/buildDOtherSide.sh
OPENSSL_SCRIPT := $(SCRIPTS_PATH)/$(OS)/buildOpenSSL.sh
QRCODEGEN_SCRIPT := $(SCRIPTS_PATH)/buildQRCodeGen.sh
PCRE_SCRIPT := $(SCRIPTS_PATH)/buildPCRE.sh
NIM_STATUS_CLIENT_SCRIPT := $(SCRIPTS_PATH)/buildNimStatusClient.sh
APP_SCRIPT := $(SCRIPTS_PATH)/buildApp.sh
RUN_SCRIPT := $(SCRIPTS_PATH)/$(OS)/run.sh

# lib files
STATUS_GO_LIB := $(LIB_PATH)/libstatus$(LIB_EXT)
STATUS_Q_LIB := $(LIB_PATH)/libStatusQ$(LIB_SUFFIX)$(LIB_EXT)
OPENSSL_LIB := $(LIB_PATH)/libssl_1_1$(LIB_EXT)
QRCODEGEN_LIB := $(LIB_PATH)/libqrcodegen.a
PCRE_LIB := $(LIB_PATH)/libpcre$(LIB_EXT)
QZXING_LIB := $(LIB_PATH)/libqzxing.a
NIM_STATUS_CLIENT_LIB := $(LIB_PATH)/libnim_status_client$(LIB_EXT)
STATUS_DESKTOP_RCC := $(STATUS_DESKTOP)/ui/resources.qrc
ifeq ($(OS), ios)
DOTHERSIDE_LIB := $(LIB_PATH)/libDOtherSideStatic$(LIB_SUFFIX)$(LIB_EXT)
else
DOTHERSIDE_LIB := $(LIB_PATH)/libDOtherSide$(LIB_SUFFIX)$(LIB_EXT)
endif

# default rule
default: makedir all

iosdevice: IPHONE_SDK=iphoneos
iosdevice: default

# dependencies
status-go: clean-status-go $(STATUS_GO_LIB)
statusq: clean-statusq $(STATUS_Q_LIB)
dotherside: clean-dotherside $(DOTHERSIDE_LIB)
openssl: clean-openssl $(OPENSSL_LIB)
qrcodegen: clean-qrcodegen $(QRCODEGEN_LIB)
pcre: clean-pcre $(PCRE_LIB)
nim-status-client: clean-nim-status-client $(NIM_STATUS_CLIENT_LIB)
status-desktop-rcc: clean-status-desktop-rcc $(STATUS_DESKTOP_RCC)

$(STATUS_GO_LIB): $(STATUS_GO_FILES)
	@echo "Building Status Go"
	@STATUS_GO=$(STATUS_GO) $(STATUS_GO_SCRIPT) $(HANDLE_OUTPUT)
	@echo "Status Go built $(STATUS_GO_LIB)"

$(STATUS_Q_LIB): $(STATUS_Q_FILES) $(STATUS_Q_SCRIPT) $(STATUS_Q_UI_FILES)
	@echo "Building StatusQ"
	@STATUSQ=$(STATUSQ) QT_VERSION=$(QT_VERSION) LIB_SUFFIX=$(LIB_SUFFIX) LIB_EXT=$(LIB_EXT) $(STATUS_Q_SCRIPT) $(HANDLE_OUTPUT)
	@echo "StatusQ built $(STATUS_Q_LIB)"

$(DOTHERSIDE_LIB): $(DOTHERSIDE_FILES) $(DOTHERSIDE_SCRIPT)
	@echo "Building DOtherSide"
	@DOTHERSIDE=$(DOTHERSIDE) QT_VERSION=$(QT_VERSION) LIB_SUFFIX=$(LIB_SUFFIX) LIB_EXT=$(LIB_EXT) $(DOTHERSIDE_SCRIPT) $(HANDLE_OUTPUT)
	@echo "DOtherSide built $(DOTHERSIDE_LIB)"

ifeq ($(OS), ios)
$(OPENSSL_LIB): $(OPENSSL_FILES)
	@echo "Building OpenSSL"
	@cd $(OPENSSL) && LIB_PATH=$(LIB_PATH) CC=clang CXX=clang++ $(OPENSSL_SCRIPT) $(HANDLE_OUTPUT)
else
$(OPENSSL_LIB):
	@echo "Copy OpenSSL"
	@cp $(ROOT_DIR)/vendors/android_openssl/ssl_1.1/$(ANDROID_ABI)/libcrypto_1_1.so $(LIB_PATH)/libcrypto_1_1.so
	@cp $(ROOT_DIR)/vendors/android_openssl/ssl_1.1/$(ANDROID_ABI)/libssl_1_1.so $(LIB_PATH)/libssl_1_1.so
	@echo "OpenSSL copied"
endif

$(QRCODEGEN_LIB): $(QRCODEGEN_FILES)
	@echo "Building QRCodeGen"
	@QRCODEGEN=$(QRCODEGEN) $(QRCODEGEN_SCRIPT) $(HANDLE_OUTPUT)
	@echo "QRCodeGen built $(QRCODEGEN_LIB)"

$(PCRE_LIB): $(PCRE_FILES)
	@echo "Building PCRE"
	@PCRE=$(PCRE) $(PCRE_SCRIPT) $(HANDLE_OUTPUT)
	@echo "PCRE built $(PCRE_LIB)"

$(STATUS_DESKTOP_RCC): $(STATUS_DESKTOP_UI_FILES)
	@echo "Building Status Desktop rcc"
	@make -C $(STATUS_DESKTOP) rcc $(HANDLE_OUTPUT)
	@echo "Status Desktop rcc built"

$(NIM_STATUS_CLIENT_LIB): $(STATUS_DESKTOP_NIM_FILES) $(NIM_STATUS_CLIENT_SCRIPT) $(STATUS_DESKTOP_RCC) $(DOTHERSIDE_LIB) $(OPENSSL_LIB) $(STATUS_Q_LIB) $(STATUS_GO_LIB) $(PCRE_LIB) $(QRCODEGEN_LIB)
	@echo "Building Status Desktop Lib"
	@STATUS_DESKTOP=$(STATUS_DESKTOP) HOST_ENV="$(HOST_ENV)" LIB_SUFFIX=$(LIB_SUFFIX) LIB_EXT=$(LIB_EXT) $(NIM_STATUS_CLIENT_SCRIPT) $(HANDLE_OUTPUT)
	@echo "Status Desktop Lib built $(NIM_STATUS_CLIENT_LIB)"

# non-phony targets
$(TARGET): $(APP_SCRIPT) $(STATUS_GO_LIB) $(STATUS_Q_LIB) $(DOTHERSIDE_LIB) $(OPENSSL_LIB) $(QRCODEGEN_LIB) $(PCRE_LIB) $(NIM_STATUS_CLIENT_LIB) $(STATUS_DESKTOP_RCC) $(COMPAT_QRC_FILE) $(DUMMY_QML_FILE)
	@echo "Building app"
	@BIN_DIR=$(BIN_PATH) BUILD_DIR=$(BUILD_PATH) QT_VERSION=$(QT_VERSION) $(APP_SCRIPT) $(HANDLE_OUTPUT)
	@echo "Built $(TARGET)"

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(BIN_PATH) $(LIB_PATH) $(BUILD_PATH)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean: clean-status-go clean-statusq clean-dotherside clean-openssl clean-qrcodegen clean-pcre clean-nim-status-client clean-status-desktop-rcc
	@echo "Cleaning"
	@rm -rf $(ROOT_DIR)bin $(ROOT_DIR)build $(ROOT_DIR)lib
	@rm -rf ${PCRE}/build

.PHONY: run
run: makedir $(TARGET)
	@echo "Running"
	@APP=$(TARGET) QT_VERSION=$(QT_VERSION) $(RUN_SCRIPT)

.PHONY: clean-status-go
clean-status-go:
	@rm -f $(STATUS_GO_LIB)
	@rm -rf $(STATUS_GO)/build

.PHONY: clean-statusq
clean-statusq:
	@rm -f $(STATUS_Q_LIB)
	@rm -rf $(STATUSQ)/build

.PHONY: clean-dotherside
clean-dotherside:
	@rm -f $(DOTHERSIDE_LIB)
	@rm -rf $(DOTHERSIDE)/build

.PHONY: clean-openssl
clean-openssl:
	@rm -f $(OPENSSL_LIB)

.PHONY: clean-qrcodegen
clean-qrcodegen:
	@rm -f $(QRCODEGEN_LIB)
	@cd $(QRCODEGEN) && make clean

.PHONY: clean-pcre
clean-pcre:
	@rm -f $(PCRE_LIB)

.PHONY: clean-nim-status-client
clean-nim-status-client:
	@rm -f $(NIM_STATUS_CLIENT_LIB)
	@rm -rf $(STATUS_DESKTOP)/nimcache

.PHONY: clean-status-desktop-rcc
clean-status-desktop-rcc:
	@rm -f $(STATUS_DESKTOP_RCC)
	@rm -f $(STATUS_DESKTOP)/resources.rcc
	@rm -f $(STATUS_DESKTOP)/ui/resources.qrc