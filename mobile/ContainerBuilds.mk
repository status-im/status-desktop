-include ./scripts/Common.mk

# Supported architectures
# arm64: arm64-v8a
# arm: armeabi-v7a
# x86_64: x86_64
# x86: x86
ARCH?=$(shell uname -m)

$(TARGET): $(STATUS_DESKTOP_NIM_FILES) $(STATUS_DESKTOP_UI_FILES) $(STATUS_Q_FILES) $(STATUS_Q_UI_FILES) $(STATUS_GO_FILES) $(DOTHERSIDE_FILES) $(OPENSSL_FILES) $(QRCODEGEN_FILES) $(PCRE_FILES) $(WRAPPER_APP_FILES)
	@echo "Building GitHub task"
	act -j android-build --container-architecture linux/amd64 --env-file $(ROOT_DIR)/.github/workflows/.env-android-$(ARCH) linux/amd64 -r
	@echo "Copying target to docker container $(shell docker ps -a --format '{{.Names}}' | grep Android-Build-APK)"
	@mkdir -p $(BIN_PATH)
	@docker cp $(shell docker ps -a --format '{{.Names}}' | grep Android-Build-APK):$(TARGET) $(BIN_PATH)


run: $(TARGET)
	@echo "Running GitHub task"
	@APP=$(TARGET) QT_VERSION=$(QT_VERSION) ADB=$(shell which adb) EMULATOR=$(shell which emulator) AVDMANAGER=$(shell which avdmanager) SDKMANAGER=$(shell which sdkmanager) $(RUN_SCRIPT)

clean:
	@echo "Cleaning GitHub task"
	@docker rm -f $(shell docker ps -a --format '{{.Names}}' | grep Android-Build-APK)
	@rm -rf $(ROOT_DIR)/bin $(ROOT_DIR)/build $(ROOT_DIR)/lib

default: $(TARGET)