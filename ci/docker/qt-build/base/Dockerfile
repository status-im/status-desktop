FROM statusteam/appimage-builder:noble

WORKDIR /root

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install \
        build-essential cmake freeglut3-dev gdb iputils-ping libgl1-mesa-dev \
        libglu1-mesa-dev libjpeg-dev libmysqlclient-dev libnss3-dev libopus-dev \
        libpng-dev libsqlite3-dev libssl-dev libx11-xcb-dev libxcb-xinerama0-dev \
        libxcb-xkb-dev libxcb1-dev libxcursor-dev libxi-dev libxml2-dev libxrender-dev \
        libxslt-dev lzip mesa-common-dev nano perl python3 valgrind wget zlib1g-dev \
        '^libxcb.*-dev' libxkbcommon-dev libxkbcommon-x11-dev wget libwayland-dev ninja-build && \
    apt-get -y install flex bison gperf libicu-dev libxslt-dev ruby && \
    apt-get -y install libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev \
        libxtst-dev libxss-dev libdbus-1-dev libevent-dev libfontconfig1-dev \
        libcap-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev \
        libegl1-mesa-dev gperf bison nodejs && \
    apt-get -y install libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev libcups2-dev \
        libavformat60 libavcodec60 libavutil58 libswresample4 libswscale7 libavdevice60 \
        libmng2 libwebp7 libxcb-xinput0 libwebpmux3 libvpx9 libzstd1 libpcre2-16-0 libxshmfence1 libclang1 \
        libllvm16t64 libxkbfile1 libbluetooth3 libsctp1 libsnappy1v5 libmd4c0 libmd4c-html0 libharfbuzz0b libharfbuzz-subset0 \
        libminizip1 libb2-1 libva2 && \
    apt-get install -y protobuf-compiler curl

# webengine
RUN apt-get install zlib1g-dev libcurl4-openssl-dev libwebpdemux2 -y

ARG TARGETARCH
ARG JAVA_VERSION=17
ARG ANDROID_API_LEVEL=35
ARG ANDROID_NDK_VERSION=27.2.12479018

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_ROOT=/opt/android-sdk/ndk/${ANDROID_NDK_VERSION}

RUN \
    if [ "$TARGETARCH" != "arm64" ]; then \
        export DEBIAN_FRONTEND=noninteractive \
 &&     export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64 \
 &&     apt-get update \
 &&     apt-get install -y git git-lfs ccache \
 &&     apt-get install -y openjdk-${JAVA_VERSION}-jdk google-android-cmdline-tools-13.0-installer; \
   fi

# Android
RUN \
    if [ "$TARGETARCH" != "arm64" ]; then \
        export DEBIAN_FRONTEND=noninteractive \
 &&     export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64 \
 &&     yes | sdkmanager --sdk_root=/opt/android-sdk "platforms;android-${ANDROID_API_LEVEL}" "platform-tools" "build-tools;${ANDROID_API_LEVEL}.0.0" \
 &&     export ANDROID_SDK_ROOT=/opt/android-sdk \
 &&     yes | sdkmanager --sdk_root=/opt/android-sdk "ndk;${ANDROID_NDK_VERSION}" \
 &&     export ANDROID_NDK_ROOT=/opt/android-sdk/ndk/${ANDROID_NDK_VERSION} \
 &&     yes | sdkmanager --licenses; \
    fi

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN \
    apt-get -y autoremove \
 && apt-get -y autoclean \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*