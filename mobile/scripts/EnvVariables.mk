#OS: ios, android
OS:=$(shell qmake -query QMAKE_XSPEC | rev | cut -d '-' -f 2 | rev)
HOST_OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
#Architectures: arm64, arm, x86_64. x86_64 is default for simulator
ARCH?=$(shell uname -m)
# Detect Qt version from qmake
QT_VERSION?=$(shell qmake -query QT_VERSION | head -c 1 2>/dev/null)

ifeq ($(OS), ios)
# iOS
#SDKs: iphonesimulator, iphoneos
IPHONE_SDK?=iphonesimulator
ifeq ($(QT_VERSION),5)
IOS_TARGET?=12
else
IOS_TARGET?=16
endif

ifeq ($(IPHONE_SDK), iphoneos)
	ARCH=arm64
else
	ARCH=x86_64
endif
else ifeq ($(OS), android)

# Android
ANDROID_API?=28
SDK_PATH?=
ANDROID_NDK_HOME?=

ifeq ($(ANDROID_NDK_HOME),)
$(error "ANDROID_NDK_HOME is not set. Please set ANDROID_NDK_HOME to the path of your Android NDK.")
endif
ifeq ($(SDK_PATH),)
$(error "SDK_PATH is not set. Please set SDK_PATH to the path of your Android SDK.")
endif
else
$(error "OS=$(OS). OS not supported by build system. Please update qmake to a supported version.")
endif

# tool macros
CC := $(PWD)/scripts/$(OS)/clangWrap.sh
CXX := $(PWD)/scripts/$(OS)/clangWrap.sh

export COMPILER
export CC
export CXX
export ARCH
export OS
export HOST_OS
export QT_VERSION

ifeq ($(OS), ios)
	export SDK=$(IPHONE_SDK)
	export IOS_TARGET
	export CPATH=$(shell xcrun --sdk ${IPHONE_SDK} --show-sdk-path)/usr/include/
	export SDKROOT=$(shell xcrun --sdk ${IPHONE_SDK} --show-sdk-path)
	export LIBRARY_PATH:=${SDKROOT}/usr/lib:${LIBRARY_PATH}
	export LIB_EXT := .a
else
	export SDK_PATH
	export ANDROID_NDK_HOME
	export ANDROID_NDK_ROOT=${ANDROID_NDK_HOME}
	export ANDROID_API
	export ANDROID_HOME=${SDK_PATH}
	export ANDROID_SDK_ROOT=${SDK_PATH}
	export ANDROID_SDK=${SDK_PATH}
	export AR=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_OS}-x86_64/bin/llvm-ar
	export AS=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_OS}-x86_64/bin/llvm-as
	export RANLIB=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_OS}-x86_64/bin/llvm-ranlib
	export PATH:=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_OS}-x86_64/bin:${PATH}

	ifeq ($(ARCH), arm64)
		export ANDROID_ABI=arm64-v8a
	else ifeq ($(ARCH), arm)
		export ANDROID_ABI=armeabi-v7a
	else
		export ANDROID_ABI=x86_64
	endif
	ifeq ($(QT_VERSION),5)
		export LIB_SUFFIX= _$(ANDROID_ABI)
	endif
	export LIB_EXT := .so
endif


# Verify tools are installed
QMAKE := $(shell which qmake)
ifeq ($(QMAKE),)
  $(error qmake not found)
endif
$(info QMAKE: $(QMAKE))

RCC := $(shell which rcc)
ifeq ($(RCC),)
  $(error rcc not found)
endif
$(info RCC: $(RCC))

ifeq ($(OS),android)
  ANDROIDDEPLOYQT := $(shell which androiddeployqt)
  ifeq ($(ANDROIDDEPLOYQT),)
    $(error androiddeployqt not found)
  endif
  $(info ANDROIDDEPLOYQT: $(ANDROIDDEPLOYQT))
  
  ifeq ($(ANDROID_NDK_HOME),)
    $(error ANDROID_NDK_HOME not set)
  endif
  $(info NDK: $(ANDROID_NDK_HOME))
  
  ifeq ($(ANDROID_API),)
    $(error ANDROID_API not set)
  endif
  $(info ANDROID_API: $(ANDROID_API))
endif

ifeq ($(OS),ios)
  ifeq ($(IPHONE_SDK),)
    $(error IPHONE_SDK not set)
  endif
  $(info IPHONE_SDK: $(IPHONE_SDK))
  
  ifeq ($(IOS_TARGET),)
    $(error IOS_TARGET not set)
  endif
  $(info IOS_TARGET: $(IOS_TARGET))
endif
# end of tool verification