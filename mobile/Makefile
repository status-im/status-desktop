-include ./scripts/EnvVariables.mk
-include ./scripts/Common.mk
$(info Configuring build system for $(OS) $(ARCH) with QT $(QT_MAJOR))

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

$(STATUS_GO_LIB): $(STATUS_GO_FILES) $(STATUS_GO_SCRIPT)
	@echo "Building Status Go"
ifeq ($(OS),ios)
	@STATUS_GO=$(STATUS_GO) \
		CC="$(shell xcrun --sdk ${SDK} --find clang)" \
		CGO_CFLAGS="-arch ${ARCH} -isysroot $(shell xcrun --sdk ${IPHONE_SDK} --show-sdk-path) -miphoneos-version-min=${IOS_TARGET} -fembed-bitcode" \
		$(STATUS_GO_SCRIPT) $(HANDLE_OUTPUT)
else
	@STATUS_GO=$(STATUS_GO) $(STATUS_GO_SCRIPT) $(HANDLE_OUTPUT)
endif
	@echo "Status Go built $(STATUS_GO_LIB)"

$(STATUS_Q_LIB): $(STATUS_Q_FILES) $(STATUS_Q_SCRIPT) $(STATUS_Q_UI_FILES)
	@echo "Building StatusQ"
	@STATUSQ=$(STATUSQ) QT_MAJOR=$(QT_MAJOR) LIB_SUFFIX=$(LIB_SUFFIX) LIB_EXT=$(LIB_EXT) $(STATUS_Q_SCRIPT) $(HANDLE_OUTPUT)
	@echo "StatusQ built $(STATUS_Q_LIB)"

$(DOTHERSIDE_LIB): $(DOTHERSIDE_FILES) $(DOTHERSIDE_SCRIPT)
	@echo "Building DOtherSide"
	@DOTHERSIDE=$(DOTHERSIDE) QT_MAJOR=$(QT_MAJOR) LIB_SUFFIX=$(LIB_SUFFIX) LIB_EXT=$(LIB_EXT) $(DOTHERSIDE_SCRIPT) $(HANDLE_OUTPUT)
	@echo "DOtherSide built $(DOTHERSIDE_LIB)"

$(OPENSSL_LIB): $(OPENSSL_FILES)
	@echo "Building OpenSSL"
	@LIB_PATH=$(LIB_PATH) LIB_EXT=$(LIB_EXT) OPENSSL=$(OPENSSL) BUILD_DIR=$(BUILD_PATH) $(OPENSSL_SCRIPT) $(HANDLE_OUTPUT)

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
	@STATUS_DESKTOP=$(STATUS_DESKTOP) LIB_SUFFIX=$(LIB_SUFFIX) LIB_EXT=$(LIB_EXT) $(NIM_STATUS_CLIENT_SCRIPT) $(HANDLE_OUTPUT)
	@echo "Status Desktop Lib built $(NIM_STATUS_CLIENT_LIB)"

# non-phony targets
$(TARGET): $(APP_SCRIPT) $(STATUS_GO_LIB) $(STATUS_Q_LIB) $(DOTHERSIDE_LIB) $(OPENSSL_LIB) $(QRCODEGEN_LIB) $(PCRE_LIB) $(NIM_STATUS_CLIENT_LIB) $(STATUS_DESKTOP_RCC) $(WRAPPER_APP_FILES)
	@echo "Building app"
	@BIN_DIR=$(BIN_PATH) BUILD_DIR=$(BUILD_PATH) QT_MAJOR=$(QT_MAJOR) $(APP_SCRIPT) $(HANDLE_OUTPUT)
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
	@rm -rf $(ROOT_DIR)/bin $(ROOT_DIR)/build $(ROOT_DIR)/lib
	@rm -rf ${PCRE}/build

.PHONY: run
run: makedir $(TARGET)
	@echo "Running"
	@APP=$(TARGET) QT_MAJOR=$(QT_MAJOR) $(RUN_SCRIPT)

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
	@make -C $(STATUS_DESKTOP) clean

.PHONY: clean-status-desktop-rcc
clean-status-desktop-rcc:
	@rm -f $(STATUS_DESKTOP_RCC)
	@rm -f $(STATUS_DESKTOP)/resources.rcc
	@rm -f $(STATUS_DESKTOP)/ui/resources.qrc
