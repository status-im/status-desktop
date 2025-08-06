# BUILD STAGE - image for build tools and source compilation
FROM ubuntu:22.04 AS builder

ARG QT_VERSION="6.9.1"
ARG GOLANG_VERSION="1.23.10"
ARG PROTOC_VERSION="3.20.0"
ARG ANDROID_BUILD_TOOLS="35.0.0"
ARG ANDROID_PLATFORM="android-35"
ARG NDK_VERSION="27.2.12479018"

LABEL stage="builder"
LABEL qt.version="${QT_VERSION}"
LABEL build.date="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV ANDROID_NDK_ROOT="/opt/android-sdk/ndk/${NDK_VERSION}"
ENV ANDROID_SDK_HOME="/opt/android-sdk"
ENV ANDROID_NDK_HOME="/opt/android-sdk/ndk/${NDK_VERSION}"
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Create jenkins user early with specific UID/GID for compatibility
RUN groupadd -g 1001 jenkins && useradd -r -g jenkins -m -d /home/jenkins -s /bin/bash -u 1001 jenkins

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

RUN mkdir -p /opt/android-sdk /opt/qt/${QT_VERSION} \
    && chown -R jenkins:jenkins /opt/android-sdk /opt/qt

RUN cd /opt/android-sdk \
    && CMDTOOLS_SHA256="2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258" \
    && CMDTOOLS_ZIP="commandlinetools-linux-11076708_latest.zip" \
    && wget -q "https://dl.google.com/android/repository/${CMDTOOLS_ZIP}" \
    && echo "${CMDTOOLS_SHA256} ${CMDTOOLS_ZIP}" | sha256sum -c \
    && unzip -q "${CMDTOOLS_ZIP}" && rm "${CMDTOOLS_ZIP}" \
    && mkdir -p cmdline-tools/latest \
    && mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true \
    && chown -R jenkins:jenkins /opt/android-sdk

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

# Set PATH for Android SDK tools
ENV PATH="/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/usr/local/go/bin:${PATH}"

USER jenkins
WORKDIR /home/jenkins

# Accept licenses and install Android components
RUN yes | sdkmanager --licenses >/dev/null 2>&1 \
    && sdkmanager "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS}" "platforms;${ANDROID_PLATFORM}" \
    && sdkmanager "ndk;${NDK_VERSION}"

RUN go install github.com/go-bindata/go-bindata/v3/go-bindata@latest \
    && go install go.uber.org/mock/mockgen@v0.4.0

RUN python3 -m venv /home/jenkins/aqt-venv \
    && /home/jenkins/aqt-venv/bin/pip install --upgrade pip \
    && /home/jenkins/aqt-venv/bin/pip install git+https://github.com/miurahr/aqtinstall.git@v3.3.0

ENV PATH="/home/jenkins/aqt-venv/bin:/home/jenkins/go/bin:${PATH}"

RUN echo "=== Installing Qt Desktop ===" \
    && aqt install-qt linux desktop ${QT_VERSION} linux_gcc_64 \
        --outputdir /opt/qt \
       --modules qt5compat \
    && echo "Qt Desktop installation completed"

RUN echo "=== Installing Qt Android arm64-v8a ===" \
    && aqt install-qt linux android ${QT_VERSION} android_arm64_v8a \
        --outputdir /opt/qt \
        --modules qtimageformats qtmultimedia qtwebview qt5compat \
    && echo "Qt Android installations completed"

RUN set -e \
    && git clone --depth 1 --branch openssl-3.0.15 https://github.com/openssl/openssl.git \
    && mkdir -p openssl-output/arm64-v8a \
    && cd openssl \
    && echo "Building OpenSSL for arm64-v8a..." \
    && export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT} \
    && export PATH=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH \
    && ./Configure android-arm64 \
        -D__ANDROID_API__=21 \
        --prefix=/home/jenkins/openssl-output/arm64-v8a \
        --openssldir=/home/jenkins/openssl-output/arm64-v8a \
        no-shared \
        no-tests \
    && make -j$(($(nproc))) \
    && make install_sw \
    && make clean \
    && echo "OpenSSL builds completed"

# RUNTIME STAGE - image with runtime dependencies
FROM ubuntu:22.04 AS runtime

ARG QT_VERSION="6.9.1"
ARG GOLANG_VERSION="1.23.10"
ARG NDK_VERSION="27.2.12479018"

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

# Create jenkins user with same UID/GID as builder stage
RUN groupadd -g 1001 jenkins && useradd -r -g jenkins -m -d /home/jenkins -s /bin/bash -u 1001 jenkins

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

RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir /nix && chown jenkins:jenkins /nix

COPY --from=builder --chown=jenkins:jenkins /opt/qt /opt/qt
COPY --from=builder --chown=jenkins:jenkins /opt/android-sdk /opt/android-sdk
COPY --from=builder /usr/local/go /usr/local/go
COPY --from=builder /usr/local/bin/protoc /usr/local/bin/protoc
COPY --from=builder /usr/local/include/google /usr/local/include/google
COPY --from=builder --chown=jenkins:jenkins /home/jenkins/go/bin /home/jenkins/go/bin
COPY --from=builder --chown=jenkins:jenkins /home/jenkins/openssl-output /home/jenkins/openssl-output

RUN /usr/local/go/bin/go install github.com/go-bindata/go-bindata/v3/go-bindata@latest \
    && /usr/local/go/bin/go install go.uber.org/mock/mockgen@v0.4.0 \
    && /usr/local/go/bin/go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1 \
    && cp /root/go/bin/* /usr/local/bin/ 2>/dev/null || true

RUN ln -sf /usr/local/go/bin/go /usr/local/bin/go \
    && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt \
    && ln -sf /usr/local/go/bin/godoc /usr/local/bin/godoc

RUN echo "/opt/qt/${QT_VERSION}/gcc_64/lib" > /etc/ld.so.conf.d/qt.conf \
    && ldconfig

RUN mkdir -p /opt/qt/${QT_VERSION}/android_arm64_v8a/lib/pkgconfig

USER jenkins

RUN curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y \
    && /home/jenkins/.nimble/bin/choosenim 2.0.12

RUN curl -s https://nixos.org/releases/nix/nix-2.24.11/install | sh -s -- --no-daemon

USER root
RUN ln -sf /home/jenkins/.choosenim/toolchains/nim-2.0.12/bin/nim /usr/local/bin/nim \
    && ln -sf /home/jenkins/.choosenim/toolchains/nim-2.0.12/bin/nimble /usr/local/bin/nimble \
    && ln -sf /home/jenkins/.choosenim/toolchains/nim-2.0.12/bin/choosenim /usr/local/bin/choosenim \
    && chmod 755 /home/jenkins/.choosenim/toolchains/nim-2.0.12/bin/* \
    && chown -R root:root /home/jenkins/.choosenim/toolchains/nim-2.0.12/bin

ENV PATH="/opt/qt/${QT_VERSION}/gcc_64/bin:/opt/qt/${QT_VERSION}/android_arm64_v8a/bin:/usr/local/go/bin:/home/jenkins/go/bin:/opt/qt/${QT_VERSION}/gcc_64/libexec:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/home/jenkins/.nix-profile/bin:/usr/local/bin:${PATH}"
ENV QT_HOST_PATH="/opt/qt/${QT_VERSION}/gcc_64/"
ENV QT_PLUGIN_PATH="/opt/qt/${QT_VERSION}/gcc_64/plugins"
ENV OPENSSL_LIB_DIR="/home/jenkins/openssl-output/arm64-v8a/lib"
ENV OPENSSL_INC_DIR="/home/jenkins/openssl-output/arm64-v8a/include"

USER jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["/bin/bash", "-l", "-c"]

LABEL maintainer="siddarth@status.im"
LABEL source="https://github.com/status-im/status-desktop"
LABEL description="Build image for the Status App Android APK."
