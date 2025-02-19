ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
HOST_ENV=$(shell printenv)

# verbosity level
V := 0
ifeq ($(V), 0)
  HANDLE_OUTPUT := >/dev/null 2>&1
endif

$(info Configuring build system)
-include $(ROOT_DIR)/scripts/EnvVariables.mk

# path macros
BIN_PATH := $(ROOT_DIR)bin/$(OS)
LIB_PATH := $(ROOT_DIR)lib/$(OS)
BUILD_PATH := $(ROOT_DIR)build/$(OS)
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

project_name := IOS-build

# compile macros
TARGET_NAME := IOS-build.$(shell if [ $(OS) = "ios" ]; then echo "app"; else echo "apk"; fi )

TARGET := $(BIN_PATH)/$(TARGET_NAME)

# src files & obj files
STATUS_DESKTOP_NIM_FILES := $(shell find -E $(STATUS_DESKTOP)/src -type f -iregex '.*\.(nim|nims)$$')
STATUS_DESKTOP_UI_FILES := $(shell find -E $(STATUS_DESKTOP)/ui -type f -iregex '.*(qmldir|qml|qrc)$$' -not -iname 'resources.qrc' -not -path $(STATUS_DESKTOP)/ui/StatusQ)
STATUS_Q_FILES := $(shell find $(STATUSQ) -type f -iregex '.*\.(cpp|h)$$' -not -name '*.qrc' -not -name '*.qml')
STATUS_Q_UI_FILES := $(shell find -E $(STATUSQ) -type f -iregex '.*\.(qml|qrc)$$')
STATUS_GO_FILES := $(shell find $(STATUS_GO) -type f)
STATUS_GO_SCRIPT := $(SCRIPTS_PATH)/buildStatusGo.sh
DOTHERSIDE_FILES := $(shell find $(DOTHERSIDE) -type f -iregex '.*\.(cpp|h)$$')
OPENSSL_FILES := $(shell find $(OPENSSL)/OpenSSL-for-iOS -type f)
QRCODEGEN_FILES := $(shell find $(QRCODEGEN) -type f -iregex '.*\.(c|h)$$')
PCRE_FILES := $(shell find $(PCRE) -type f)
WRAPPER_APP_FILES := $(shell find $(WRAPPER_APP) -type f)

# script files
STATUS_Q_SCRIPT := $(SCRIPTS_PATH)/buildStatusQ.sh
STATUS_GO_SCRIPT := $(SCRIPTS_PATH)/buildStatusGo.sh
DOTHERSIDE_SCRIPT := $(SCRIPTS_PATH)/buildDOtherSide.sh
OPENSSL_SCRIPT := $(SCRIPTS_PATH)/buildOpenSSL.sh
QRCODEGEN_SCRIPT := $(SCRIPTS_PATH)/buildQRCodeGen.sh
PCRE_SCRIPT := $(SCRIPTS_PATH)/buildPCRE.sh
NIM_STATUS_CLIENT_SCRIPT := $(SCRIPTS_PATH)/buildNimStatusClient.sh
APP_SCRIPT := $(SCRIPTS_PATH)/buildApp.sh
RUN_SCRIPT := $(SCRIPTS_PATH)/$(OS)/run.sh

# lib files
STATUS_GO_LIB := $(LIB_PATH)/libstatus$(LIBEXT)
STATUS_Q_LIB := $(LIB_PATH)/libStatusQ$(LIBSUFFIX)$(LIBEXT)
DOTHERSIDE_LIB := $(LIB_PATH)/libDOtherSide$(LIBSUFFIX)$(LIBEXT)
OPENSSL_LIB := $(LIB_PATH)/libssl_1_1$(LIBEXT)
QRCODEGEN_LIB := $(LIB_PATH)/libqrcodegen.a
PCRE_LIB := $(LIB_PATH)/libpcre$(LIBEXT)
QZXING_LIB := $(LIB_PATH)/libqzxing.a
NIM_STATUS_CLIENT_LIB := $(LIB_PATH)/libnim_status_client$(LIBEXT)
STATUS_DESKTOP_RCC := $(STATUS_DESKTOP)/ui/resources.qrc

# default rule
default: makedir all

iosdevice: IPHONE_SDK=iphoneos
iosdevice: default

# dependencies
status-go: $(STATUS_GO_LIB)
statusq: $(STATUS_Q_LIB)
dotherside: $(DOTHERSIDE_LIB)
openssl: $(OPENSSL_LIB)
qrcodegen: $(QRCODEGEN_LIB)
pcre: $(PCRE_LIB)
nim-status-client: $(NIM_STATUS_CLIENT_LIB)
status-desktop-rcc: $(STATUS_DESKTOP_RCC)

$(STATUS_GO_LIB): $(STATUS_GO_FILES)
	@echo "Building Status Go"
	@STATUS_GO=$(STATUS_GO) $(STATUS_GO_SCRIPT) $(HANDLE_OUTPUT)
	@echo "Status Go built $(STATUS_GO_LIB)"

$(STATUS_Q_LIB): $(STATUS_Q_FILES) $(STATUS_Q_SCRIPT)
	@echo "Building StatusQ"
	@STATUSQ=$(STATUSQ) $(STATUS_Q_SCRIPT) $(HANDLE_OUTPUT)
	@echo "StatusQ built $(STATUS_Q_LIB)"

$(DOTHERSIDE_LIB): $(DOTHERSIDE_FILES) $(DOTHERSIDE_SCRIPT)
	@echo "Building DOtherSide"
	@DOTHERSIDE=$(DOTHERSIDE) $(DOTHERSIDE_SCRIPT) $(HANDLE_OUTPUT)
	@echo "DOtherSide built $(DOTHERSIDE_LIB)"

ifeq ($(OS), ios)
$(OPENSSL_LIB): $(OPENSSL_FILES)
	@echo "Building OpenSSL"
	@cd $(OPENSSL) && LIB_PATH=$(LIB_PATH) CC=clang CXX=clang++ $(OPENSSL_SCRIPT) $(HANDLE_OUTPUT)
else
$(OPENSSL_LIB):
	@echo "Copy OpenSSL"
	@cp $(SDK_PATH)/android_openssl/ssl_1.1/$(ANDROID_ABI)/libcrypto_1_1.so $(LIB_PATH)/libcrypto_1_1.so
	@cp $(SDK_PATH)/android_openssl/ssl_1.1/$(ANDROID_ABI)/libssl_1_1.so $(LIB_PATH)/libssl_1_1.so
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
	make -C $(STATUS_DESKTOP) rcc $(HANDLE_OUTPUT)
	@echo "Status Desktop rcc built"

$(NIM_STATUS_CLIENT_LIB): $(STATUS_DESKTOP_NIM_FILES) $(NIM_STATUS_CLIENT_SCRIPT)
	@echo "Building Status Desktop Lib"
	@STATUS_DESKTOP=$(STATUS_DESKTOP) HOST_ENV="$(HOST_ENV)" $(NIM_STATUS_CLIENT_SCRIPT) $(HANDLE_OUTPUT)
	@echo "Status Desktop Lib built $(NIM_STATUS_CLIENT_LIB)"

# non-phony targets
$(TARGET): $(APP_SCRIPT) $(STATUS_GO_LIB) $(STATUS_Q_LIB) $(DOTHERSIDE_LIB) $(OPENSSL_LIB) $(QRCODEGEN_LIB) $(PCRE_LIB) $(NIM_STATUS_CLIENT_LIB) $(STATUS_DESKTOP_RCC)
	@echo "Building app"
	@BIN_DIR=$(BIN_PATH) BUILD_DIR=$(BUILD_PATH) $(APP_SCRIPT) $(HANDLE_OUTPUT)
	@echo "Built $(TARGET)"

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(BIN_PATH) $(LIB_PATH) $(BUILD_PATH)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	@echo "Cleaning"
	@rm -rf $(ROOT_DIR)bin $(ROOT_DIR)build $(ROOT_DIR)lib
	@cd $(STATUS_DESKTOP) && make clean
	@rm -rf ${PCRE}/build

.PHONY: run
run: makedir $(TARGET)
	@echo "Running"
	@APP=$(TARGET) $(RUN_SCRIPT)

