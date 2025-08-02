# BUILD STAGE - image for build tools and source compilation
FROM ubuntu:22.04 AS builder

ARG QT_VERSION="6.9.0"
ARG FFMPEG_VERSION="7.1"
ARG GOLANG_VERSION="1.23.10"
ARG PROTOC_VERSION="3.20.0"
ARG ANDROID_BUILD_TOOLS="34.0.0"
ARG ANDROID_PLATFORM="android-34"
ARG NDK_VERSION="26.1.10909125"

LABEL stage="builder"
LABEL qt.version="${QT_VERSION}"
LABEL build.date="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV ANDROID_NDK_ROOT="/opt/android-sdk/ndk/${NDK_VERSION}"
ENV ANDROID_SDK_HOME="/opt/android-sdk"
ENV ANDROID_NDK_HOME="/opt/android-sdk/ndk/${NDK_VERSION}"
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

RUN groupadd -r builder && useradd -r -g builder -m -d /home/builder -s /bin/bash builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    wget \
    build-essential \
    software-properties-common \
    gnupg2 \
    ca-certificates \
    locales \
    file \
    xz-utils \
    python3 \
    python3-pip \
    python3-venv \
    perl \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:git-core/ppa \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update && apt-get install -y --no-install-recommends \
    gcc-9 \
    g++-9 \
    cmake \
    ninja-build \
    make \
    pkg-config \
    autoconf \
    automake \
    libtool \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-dev \
    libfontconfig1 \
    libdbus-1-3 \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libsqlite3-dev \
    libpcre3-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/android-sdk && cd /opt/android-sdk \
    && CMDTOOLS_SHA256="2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258" \
    && CMDTOOLS_ZIP="commandlinetools-linux-11076708_latest.zip" \
    && wget -q "https://dl.google.com/android/repository/${CMDTOOLS_ZIP}" \
    && echo "${CMDTOOLS_SHA256} ${CMDTOOLS_ZIP}" | sha256sum -c \
    && unzip -q "${CMDTOOLS_ZIP}" && rm "${CMDTOOLS_ZIP}" \
    && mkdir -p cmdline-tools/latest \
    && mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true \
    && chown -R builder:builder /opt/android-sdk

ENV PATH="/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:${PATH}"

# Accept licenses and install Android components
USER builder
RUN yes | sdkmanager --licenses >/dev/null 2>&1 \
    && sdkmanager "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS}" "platforms;${ANDROID_PLATFORM}" \
    && sdkmanager "ndk;${NDK_VERSION}"

USER root

RUN GOLANG_SHA256="535f9f81802499f2a7dbfa70abb8fda3793725fcc29460f719815f6e10b5fd60" \
    && GOLANG_TARBALL="go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && wget -q "https://dl.google.com/go/${GOLANG_TARBALL}" \
    && echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c \
    && tar -C /usr/local -xzf "${GOLANG_TARBALL}" \
    && rm "${GOLANG_TARBALL}" \
    && ln -sf /usr/local/go/bin/go /usr/local/bin/go \
    && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

RUN PROTOC_SHA256="75d8a9d7a2c42566e46411750d589c51276242d8b6247a5724bac0f9283e05a8" \
    && PROTOC_TARBALL="protoc-${PROTOC_VERSION}-linux-x86_64.zip" \
    && wget -q "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC_TARBALL}" \
    && echo "${PROTOC_SHA256} ${PROTOC_TARBALL}" | sha256sum -c \
    && unzip -q -d /usr/local "${PROTOC_TARBALL}" \
    && rm "${PROTOC_TARBALL}"

RUN PROTOC_GEN_SHA256="0b2c257938a8cd9ba3506bbdbbaad45e51245b6f9e0743035ade7acf746c6be7" \
    && PROTOC_GEN_TARBALL="protoc-gen-go.v1.34.1.linux.amd64.tar.gz" \
    && wget -q "https://github.com/protocolbuffers/protobuf-go/releases/download/v1.34.1/${PROTOC_GEN_TARBALL}" \
    && echo "${PROTOC_GEN_SHA256} ${PROTOC_GEN_TARBALL}" | sha256sum -c \
    && tar -C /usr/local/bin -xzf "${PROTOC_GEN_TARBALL}" \
    && rm "${PROTOC_GEN_TARBALL}"

RUN mkdir -p /opt/qt/${QT_VERSION} \
    && chown -R builder:builder /opt/qt

USER builder
WORKDIR /home/builder

ENV PATH="/usr/local/go/bin:/home/builder/go/bin:${PATH}"
RUN go install github.com/go-bindata/go-bindata/v3/go-bindata@latest \
    && go install go.uber.org/mock/mockgen@v0.4.0

# pin aqt to 3.3.0
RUN python3 -m venv /home/builder/aqt-venv \
    && /home/builder/aqt-venv/bin/pip install --upgrade pip \
    && /home/builder/aqt-venv/bin/pip install git+https://github.com/miurahr/aqtinstall.git@v3.3.0

ENV PATH="/home/builder/aqt-venv/bin:${PATH}"

# Qt Desktop is needed for Android QT
RUN echo "=== Installing Qt Desktop ===" \
    && aqt install-qt linux desktop ${QT_VERSION} linux_gcc_64 \
        --outputdir /opt/qt \
    && echo "Qt Desktop installation completed"

# TODO: we might not need the x86_64 bit
RUN echo "=== Installing Qt Android arm64-v8a ===" \
    && aqt install-qt linux android ${QT_VERSION} android_arm64_v8a \
        --outputdir /opt/qt \
        --modules qtimageformats qtmultimedia qtwebview qt5compat \
    && echo "=== Installing Qt Android x86_64 ===" \
    && aqt install-qt linux android ${QT_VERSION} android_x86_64 \
        --outputdir /opt/qt \
        --modules qtimageformats qtmultimedia qtwebview qt5compat \
    && echo "Qt Android installations completed"

# TODO: we might not need the x86_64 bit
RUN set -e \
    && git clone --depth 1 --branch openssl-3.0.15 https://github.com/openssl/openssl.git \
    && mkdir -p openssl-output/arm64-v8a openssl-output/x86_64 \
    && cd openssl \
    && echo "Building OpenSSL for arm64-v8a..." \
    && export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT} \
    && export PATH=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH \
    && ./Configure android-arm64 \
        -D__ANDROID_API__=21 \
        --prefix=/home/builder/openssl-output/arm64-v8a \
        --openssldir=/home/builder/openssl-output/arm64-v8a \
        no-shared \
        no-tests \
    && make -j$(($(nproc))) \
    && make install_sw \
    && make clean \
    && echo "Building OpenSSL for x86_64..." \
    && ./Configure android-x86_64 \
        -D__ANDROID_API__=21 \
        --prefix=/home/builder/openssl-output/x86_64 \
        --openssldir=/home/builder/openssl-output/x86_64 \
        no-shared \
        no-tests \
    && make -j$(($(nproc))) \
    && make install_sw \
    && echo "OpenSSL builds completed"

# RUNTIME STAGE - image with runtime dependencies
FROM ubuntu:22.04 AS runtime

ARG QT_VERSION="6.9.0"
ARG GOLANG_VERSION="1.23.10"
ARG NDK_VERSION="26.1.10909125"

LABEL description="Android build environment with Qt ${QT_VERSION} and nim"
LABEL qt.version="${QT_VERSION}"
LABEL base.image="ubuntu:22.04"
LABEL qt.installation.method="aqt"

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV ANDROID_NDK_ROOT="/opt/android-sdk/ndk/${NDK_VERSION}"
ENV ANDROID_SDK_HOME="/opt/android-sdk"
ENV ANDROID_NDK_HOME="/opt/android-sdk/ndk/${NDK_VERSION}"
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

RUN groupadd -r developer && useradd -r -g developer -m -d /home/developer -s /bin/bash developer

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    wget \
    build-essential \
    openjdk-17-jdk \
    libgl1-mesa-dev \
    libfontconfig1 \
    libdbus-1-3 \
    python3 \
    ca-certificates \
    sudo \
    locales \
    pkg-config \
    cmake \
    ninja-build \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo "developer ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY --from=builder --chown=developer:developer /opt/qt /opt/qt

COPY --from=builder --chown=developer:developer /opt/android-sdk /opt/android-sdk

COPY --from=builder /usr/local/go /usr/local/go

COPY --from=builder /usr/local/bin/protoc /usr/local/bin/protoc
COPY --from=builder /usr/local/include/google /usr/local/include/google

COPY --from=builder /home/builder/go/bin /home/developer/go/bin

COPY --from=builder /home/builder/openssl-output /home/developer/openssl-output

USER developer
RUN curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y \
    && /home/developer/.nimble/bin/choosenim 2.0.12

USER root
RUN ln -sf /home/developer/.choosenim/toolchains/nim-2.0.12/bin/nim /usr/local/bin/nim \
    && ln -sf /home/developer/.choosenim/toolchains/nim-2.0.12/bin/nimble /usr/local/bin/nimble \
    && ln -sf /home/developer/.choosenim/toolchains/nim-2.0.12/bin/choosenim /usr/local/bin/choosenim \
    && ln -sf /usr/local/go/bin/go /usr/bin/go \
    && ln -sf /usr/local/go/bin/gofmt /usr/bin/gofmt \
    && chmod 755 /home/developer/.choosenim/toolchains/nim-2.0.12/bin/* \
    && chown -R root:root /home/developer/.choosenim/toolchains/nim-2.0.12/bin

RUN ln -sf /usr/local/go/bin/go /usr/local/bin/go \
    && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt \
    && ln -sf /usr/local/go/bin/godoc /usr/local/bin/godoc

RUN /usr/local/go/bin/go install github.com/go-bindata/go-bindata/v3/go-bindata@latest \
    && /usr/local/go/bin/go install go.uber.org/mock/mockgen@v0.4.0 \
    && /usr/local/go/bin/go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1 \
    && cp /root/go/bin/* /usr/local/bin/ 2>/dev/null || true

# Set up library paths
RUN echo "/opt/qt/${QT_VERSION}/gcc_64/lib" > /etc/ld.so.conf.d/qt.conf \
    && ldconfig

# TODO: we might not need the x86_64 link
RUN mkdir -p /opt/qt/${QT_VERSION}/android_arm64_v8a/lib/pkgconfig \
    && mkdir -p /opt/qt/${QT_VERSION}/android_x86_64/lib/pkgconfig

ENV PATH="/opt/qt/${QT_VERSION}/gcc_64/bin:/opt/qt/${QT_VERSION}/android_arm64_v8a/bin:/opt/qt/${QT_VERSION}/android_x86_64/bin:/usr/local/go/bin:/home/developer/go/bin:/opt/qt/${QT_VERSION}/gcc_64/libexec:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/usr/local/bin:${PATH}"
ENV QT_HOST_PATH="/opt/qt/${QT_VERSION}/gcc_64/"
ENV QT_PLUGIN_PATH="/opt/qt/${QT_VERSION}/gcc_64/plugins"
ENV OPENSSL_LIB_DIR="/home/developer/openssl-output/arm64-v8a/lib"
ENV OPENSSL_INC_DIR="/home/developer/openssl-output/arm64-v8a/include"
ENV PATH="/usr/local/bin:${PATH}"

USER developer
WORKDIR /home/developer

ENTRYPOINT ["/bin/bash", "-l", "-c"]

# Usage documentation
LABEL description="Build image for the Status-tablet Android APK."
