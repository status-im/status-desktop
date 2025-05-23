SHELL:=/bin/bash
ROOT_DIR := $(shell git rev-parse --show-toplevel)
HOST_ENV=$(shell printenv)
OS?=android
QT_VERSION?=6

# verbosity level
V := 0
ifeq ($(V), 0)
  HANDLE_OUTPUT := >/dev/null 2>&1
endif

# path macros
BIN_PATH := $(ROOT_DIR)/bin/$(OS)/qt$(QT_VERSION)
LIB_PATH := $(ROOT_DIR)/lib/$(OS)/qt$(QT_VERSION)
BUILD_PATH := $(ROOT_DIR)/build/$(OS)/qt$(QT_VERSION)
SCRIPTS_PATH := $(ROOT_DIR)/scripts

export LIB_DIR=$(LIB_PATH)

WRAPPER_APP?=$(ROOT_DIR)/wrapperApp
STATUS_DESKTOP?=$(ROOT_DIR)/vendors/status-desktop
STATUSQ?=$(STATUS_DESKTOP)/ui/StatusQ
STATUS_GO?=$(STATUS_DESKTOP)/vendor/status-go
DOTHERSIDE?=$(STATUS_DESKTOP)/vendor/DOtherSide
OPENSSL?=$(ROOT_DIR)/vendors/OpenSSL-for-iPhone
QRCODEGEN?=$(STATUS_DESKTOP)/vendor/QR-Code-generator/c
PCRE?=$(ROOT_DIR)/vendors/pcre-8.45

project_name := Status-tablet

# compile macros
TARGET_PREFIX := Status-tablet
TARGET_NAME := $(TARGET_PREFIX).$(shell if [ $(OS) = "ios" ]; then echo "app"; else echo "apk"; fi )

TARGET := $(BIN_PATH)/$(TARGET_NAME)

# src files & obj files
STATUS_DESKTOP_NIM_FILES := $(shell find $(STATUS_DESKTOP)/src -type f \( -iname '*.nim' -o -iname '*.nims' \))
STATUS_DESKTOP_UI_FILES := $(shell find $(STATUS_DESKTOP)/ui -type f \( -iname 'qmldir' -o -iname '*.qml' -o -iname '*.qrc' \) -not -iname 'resources.qrc' -not -path '$(STATUS_DESKTOP)/ui/StatusQ/*')
STATUS_Q_FILES := $(shell find $(STATUSQ) -type f \( -iname '*.cpp' -o -iname '*.h' \) -not -iname '*.qrc' -not -iname '*.qml')
STATUS_Q_UI_FILES := $(shell find $(STATUSQ) -type f \( -iname '*.qml' -o -iname '*.qrc' \))
STATUS_GO_FILES := $(shell find $(STATUS_GO) -type f \( -iname '*.go' \))
STATUS_GO_SCRIPT := $(SCRIPTS_PATH)/buildStatusGo.sh
DOTHERSIDE_FILES := $(shell find $(DOTHERSIDE) -type f \( -iname '*.cpp' -o -iname '*.h' \))
OPENSSL_FILES := $(shell find $(OPENSSL)/OpenSSL-for-iOS -type f)
QRCODEGEN_FILES := $(shell find $(QRCODEGEN) -type f \( -iname '*.c' -o -iname '*.h' \))
PCRE_FILES := $(shell find $(PCRE) -type f)
WRAPPER_APP_FILES := $(shell find $(WRAPPER_APP) -type f)

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