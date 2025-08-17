FROM statusteam/nim-status-client-build:1.0.0-qt6.9.0-android

ARG GOLANG_VERSION="1.23.10"
ARG NIM_VERSION="2.0.12"
ARG NIX_VERSION="2.24.11"

LABEL description="Complete Android build environment with Qt, Nim, and all tooling"
LABEL qt.version="6.9.0"
LABEL nim.version="${NIM_VERSION}"
LABEL base.image="statusteam/nim-status-client-build:1.0.0-qt6.9.0-android"

ENV DEBIAN_FRONTEND=noninteractive

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
    sudo \
    pkg-config \
    cmake \
    ninja-build \
    libgl1-mesa-dev \
    libfontconfig1 \
    libdbus-1-3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Give jenkins sudo access
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir /nix && chown jenkins:jenkins /nix

RUN GOLANG_SHA256="535f9f81802499f2a7dbfa70abb8fda3793725fcc29460f719815f6e10b5fd60" \
    && GOLANG_TARBALL="go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && rm -rf /usr/local/go \
    && wget -q "https://dl.google.com/go/${GOLANG_TARBALL}" \
    && echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c \
    && tar -C /usr/local -xzf "${GOLANG_TARBALL}" \
    && rm "${GOLANG_TARBALL}" \
    && ln -sf /usr/local/go/bin/go /usr/local/bin/go \
    && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install Go tools as root first, then copy to accessible location
RUN /usr/local/go/bin/go install github.com/go-bindata/go-bindata/v3/go-bindata@latest \
    && /usr/local/go/bin/go install go.uber.org/mock/mockgen@v0.4.0 \
    && /usr/local/go/bin/go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1 \
    && cp /root/go/bin/* /usr/local/bin/ 2>/dev/null || true

RUN echo "/opt/qt/6.9.0/gcc_64/lib" > /etc/ld.so.conf.d/qt.conf \
    && ldconfig

RUN mkdir -p /opt/qt/6.9.0/android_arm64_v8a/lib/pkgconfig

# Switch to jenkins user for user-specific installations
USER jenkins
WORKDIR /home/jenkins

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
    && echo "OpenSSL build completed"

RUN curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y \
    && /home/jenkins/.nimble/bin/choosenim ${NIM_VERSION}

RUN curl -s https://nixos.org/releases/nix/nix-${NIX_VERSION}/install | sh -s -- --no-daemon

RUN /usr/local/go/bin/go install github.com/go-bindata/go-bindata/v3/go-bindata@latest \
    && /usr/local/go/bin/go install go.uber.org/mock/mockgen@v0.4.0

USER root

RUN ln -sf /home/jenkins/.choosenim/toolchains/nim-${NIM_VERSION}/bin/nim /usr/local/bin/nim \
    && ln -sf /home/jenkins/.choosenim/toolchains/nim-${NIM_VERSION}/bin/nimble /usr/local/bin/nimble \
    && ln -sf /home/jenkins/.choosenim/toolchains/nim-${NIM_VERSION}/bin/choosenim /usr/local/bin/choosenim \
    && chmod 755 /home/jenkins/.choosenim/toolchains/nim-${NIM_VERSION}/bin/* \
    && chown -R root:root /home/jenkins/.choosenim/toolchains/nim-${NIM_VERSION}/bin

ENV PATH="/opt/qt/6.9.0/gcc_64/bin:/opt/qt/6.9.0/android_arm64_v8a/bin:/usr/local/go/bin:/home/jenkins/go/bin:/opt/qt/6.9.0/gcc_64/libexec:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/home/jenkins/.nix-profile/bin:/usr/local/bin:${PATH}"
ENV QT_HOST_PATH="/opt/qt/6.9.0/gcc_64/"
ENV QT_PLUGIN_PATH="/opt/qt/6.9.0/gcc_64/plugins"
ENV OPENSSL_LIB_DIR="/home/jenkins/openssl-output/arm64-v8a/lib"
ENV OPENSSL_INC_DIR="/home/jenkins/openssl-output/arm64-v8a/include"

USER jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["/bin/bash", "-l", "-c"]

LABEL maintainer="status-team"
LABEL source="https://github.com/status-im/status-desktop"
