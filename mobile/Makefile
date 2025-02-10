# tool macros
CWD := $(PWD)
CC := $(PWD)/scripts/clangWrap.sh
CXX := $(PWD)/scripts/clangWrap.sh
#SDKs: iphonesimulator, iphoneos
SDK?=iphonesimulator
IOS_TARGET?=12
#Architectures: arm64, arm, x86_64. x86_64 is default for simulator
ARCH?=x86_64

export CC
export CXX
export SDK
export IOS_TARGET
export ARCH

# path macros
BIN_PATH := bin
LIB_PATH := lib
BUILD_PATH := build

WRAPPER_APP=$(PWD)/wrapperApp
STATUS_DESKTOP=$(PWD)/vendors/status-desktop
STATUSQ=$(STATUS_DESKTOP)/ui/StatusQ
STATUS_GO=$(STATUS_DESKTOP)/vendor/status-go
DOTHERSIDE=$(STATUS_DESKTOP)/vendor/DOtherSide
OPENSSL=$(PWD)/vendors/OpenSSL-for-iPhone
QRCODEGEN=$(STATUS_DESKTOP)/vendor/QR-Code-generator/c
PCRE=$(PWD)/vendors/pcre-8.45

project_name := IOS-build

# compile macros
TARGET_NAME := IOS-build.app

TARGET := $(BIN_PATH)/Applications/$(TARGET_NAME)

# src files & obj files
STATUS_DESKTOP_NIM_FILES := $(shell find -E $(STATUS_DESKTOP)/src -type f -iregex '.*\.(nim|nims)$$')
STATUS_DESKTOP_UI_FILES := $(shell find -E $(STATUS_DESKTOP)/ui -type f -iregex '.*(qmldir|qml|qrc)$$' -not -iname 'resources.qrc' -not -path $(STATUS_DESKTOP)/ui/StatusQ)
STATUS_Q_FILES := $(shell find $(STATUSQ) -type f -not -name '*.qrc' -not -name '*.qml')
STATUS_Q_UI_FILES := $(shell find -E $(STATUSQ) -type f -iregex '.*\.(qml|qrc)$$')
STATUS_GO_FILES := $(shell find $(STATUS_GO) -type f)
DOTHERSIDE_FILES := $(shell find $(DOTHERSIDE) -type f)
OPENSSL_FILES := $(shell find $(OPENSSL)/OpenSSL-for-iOS -type f)
QRCODEGEN_FILES := $(shell find $(QRCODEGEN) -type f)
PCRE_FILES := $(shell find $(PCRE) -type f)
WRAPPER_APP_FILES := $(shell find $(WRAPPER_APP) -type f)

STATUS_GO_LIB := $(LIB_PATH)/libstatus.a
STATUS_Q_LIB := $(LIB_PATH)/libStatusQ.a
DOTHERSIDE_LIB := $(LIB_PATH)/libDOtherSideStatic.a
OPENSSL_LIB := $(LIB_PATH)/libssl.a $(LIB_PATH)/libcrypto.a
QRCODEGEN_LIB := $(LIB_PATH)/libqrcodegen.a
PCRE_LIB := $(LIB_PATH)/libpcre.a
QZXING_LIB := $(LIB_PATH)/libqzxing.a
NIM_STATUS_CLIENT_LIB := $(LIB_PATH)/libnim_status_client.a
STATUS_DESKTOP_RCC := $(STATUS_DESKTOP)/ui/resources.qrc

# default rule
default: makedir all

$(STATUS_GO_LIB): $(STATUS_GO_FILES)
	echo "Building status-go"
	@cd $(STATUS_GO) && $(CWD)/scripts/buildStatusGo.sh
	cp $(STATUS_GO)/build/bin/libstatus.a $(STATUS_GO_LIB)

$(STATUS_Q_LIB): $(STATUS_Q_FILES)
	echo "Building StatusQ"
	@cd $(STATUSQ) && $(CWD)/scripts/buildStatusQ.sh
	cp $(STATUSQ)/build/lib/Release/libStatusQ.a $(STATUS_Q_LIB)

$(QZXING_LIB): $(STATUS_Q_LIB)
	echo "Building qzxing"
	cp $(STATUSQ)/build/lib/Release/libqzxing.a $(QZXING_LIB)

$(DOTHERSIDE_LIB): $(DOTHERSIDE_FILES)
	echo "Building DOtherSide"
	@cd $(DOTHERSIDE) && $(CWD)/scripts/buildDOtherSide.sh
	cp $(DOTHERSIDE)/build/lib/Release-$(SDK)/libDOtherSideStatic.a $(DOTHERSIDE_LIB)

$(OPENSSL_LIB): LIBEXT = $(shell if [ $(SDK) = "iphonesimulator" ]; then echo "-Sim"; else echo ""; fi)
$(OPENSSL_LIB): $(OPENSSL_FILES)
	echo "Building OpenSSL"
	@cd $(OPENSSL) && CC=clang CXX=clang++ $(CWD)/scripts/buildOpenSSL.sh
	
	cp $(OPENSSL)/lib/libcrypto-IOS$(LIBEXT).a $(LIB_PATH)/libcrypto.a
	cp $(OPENSSL)/lib/libssl-IOS$(LIBEXT).a $(LIB_PATH)/libssl.a

$(QRCODEGEN_LIB): $(QRCODEGEN_FILES)
	echo "Building QR-Code-generator"
	@cd $(QRCODEGEN) && $(CWD)/scripts/buildQRCodeGen.sh
	cp $(QRCODEGEN)/libqrcodegen.a $(QRCODEGEN_LIB)

$(PCRE_LIB): $(PCRE_FILES)
	echo "Building PCRE"
	@cd $(PCRE) && $(CWD)/scripts/buildPCRE.sh
	cp $(PCRE)/build/Release-$(SDK)/libpcre.a $(PCRE_LIB)

$(NIM_STATUS_CLIENT_LIB): $(STATUS_DESKTOP_NIM_FILES)
	echo "Building Status Desktop Lib"
	@cd $(STATUS_DESKTOP) && $(CWD)/scripts/buildNimStatusClient.sh
	cp $(STATUS_DESKTOP)/bin/libnim_status_client.a $(NIM_STATUS_CLIENT_LIB)

$(STATUS_DESKTOP_RCC): $(STATUS_DESKTOP_UI_FILES)
	echo "Building Status Desktop UI"
	@cd $(STATUS_DESKTOP) && make rcc

# non-phony targets
$(TARGET): $(STATUS_GO_LIB) $(STATUS_Q_LIB) $(DOTHERSIDE_LIB) $(OPENSSL_LIB) $(QRCODEGEN_LIB) $(PCRE_LIB) $(QZXING_LIB) $(NIM_STATUS_CLIENT_LIB) $(STATUS_DESKTOP_RCC) $(WRAPPER_APP_FILES)
	@echo "Building $(TARGET)"
	@$(CWD)/scripts/buildApp.sh

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(BIN_PATH) $(LIB_PATH) $(BUILD_PATH)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	@echo "Cleaning"
	@rm -rf $(BIN_PATH) $(LIB_PATH) $(BUILD_PATH)
	@cd $(STATUS_DESKTOP) && make clean

.PHONY: run
run: makedir $(TARGET)
	@echo "Running"
	@$(CWD)/scripts/run.sh
