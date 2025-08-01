MAKEFILE_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
QT_VERSION?=6.9.0
QT_MAJOR=$(shell echo $(QT_VERSION) | cut -d. -f1)

-include $(MAKEFILE_DIR)/scripts/Common.mk

# Supported architectures
# arm64: arm64-v8a
# arm: armeabi-v7a
# x86_64: x86_64
# x86: x86
ARCH?=$(shell uname -m)

$(TARGET): $(STATUS_DESKTOP_NIM_FILES) $(STATUS_DESKTOP_UI_FILES) $(STATUS_Q_FILES) $(STATUS_Q_UI_FILES) $(STATUS_GO_FILES) $(DOTHERSIDE_FILES) $(OPENSSL_FILES) $(QRCODEGEN_FILES) $(WRAPPER_APP_FILES)
	@echo "Building GitHub task $(TARGET) for architecture $(ARCH)"
	act -j android-build --container-architecture linux/amd64 --artifact-server-path $(BIN_PATH) -W .github/workflows/android-build.yml --input architecture=$(ARCH) --input qt_version=$(QT_VERSION) -r
	@unzip -o $(BIN_PATH)/1/$(TARGET_PREFIX)/$(TARGET_PREFIX).zip -d $(BIN_PATH)
	touch $(TARGET)

run: $(TARGET)
	@echo "Running GitHub task"
	@APP=$(TARGET) QT_MAJOR=$(QT_MAJOR) ADB=$(shell which adb) EMULATOR=$(shell which emulator) AVDMANAGER=$(shell which avdmanager) SDKMANAGER=$(shell which sdkmanager) $(RUN_SCRIPT)

clean:
	@echo "Cleaning GitHub task"
	@docker rm -f $(shell docker ps -a --format '{{.Names}}' | grep Android-Build-APK)
	@rm -rf $(ROOT_DIR)/bin $(ROOT_DIR)/build $(ROOT_DIR)/lib

default: $(TARGET)