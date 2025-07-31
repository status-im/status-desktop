# QT Installation Image --------------------------------------------------------
FROM carlonluca/qt-dev:6.9.0

ENV PATH=/opt/qt/6.9.0/android_arm64_v8a/bin:${PATH}
ENV ARCH=arm64

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    sudo \
    build-essential \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt update -yq && apt install -yq software-properties-common \
 && add-apt-repository -y ppa:git-core/ppa \
 && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
 && apt update -yq && apt full-upgrade -yq && apt install -yq --no-install-recommends --fix-missing  \
    gnupg2 openssh-client ca-certificates locales sudo jq curl wget fuse s3cmd file unzip llvm tk-dev xz-utils \
    git make build-essential pkg-config extra-cmake-modules gcc-9 g++-9 \
    libgl1-mesa-dev libsm6 libice6 libfontconfig1 libdbus-1-3 libssl-dev libz-dev \
    zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev unixodbc-dev libpq-dev \
    libncurses5-dev libncursesw5-dev libnss3 \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-alsa libpulse-mainloop-glib0 \
    gstreamer1.0-pulseaudio libgstreamer-plugins-base1.0-0 \
    libxext6 libxrender1 libxkbcommon-dev libxkbcommon-x11-dev libxcomposite1 libxtst6 \
    libxrandr2 libxcursor1 libxi6 libxcb-randr0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-render-util0 libxcb-shape0 libxcb-render0 libxcb-xinerama0 \
    autoconf automake libtool gcc \
 &&  update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
 && apt-get -qq clean

    
# Installing Golang
RUN GOLANG_SHA256="736ce492a19d756a92719a6121226087ccd91b652ed5caec40ad6dbfb2252092" \
 && GOLANG_TARBALL="go1.22.10.linux-amd64.tar.gz" \
 && wget -q "https://dl.google.com/go/${GOLANG_TARBALL}" \
 && echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c \
 && sudo tar -C /usr/local -xzf "${GOLANG_TARBALL}" \
 && rm "${GOLANG_TARBALL}" \
 && sudo ln -s /usr/local/go/bin/go /usr/local/bin

# Install Protoc
RUN PROTOC_SHA256="75d8a9d7a2c42566e46411750d589c51276242d8b6247a5724bac0f9283e05a8" \
 && PROTOC_TARBALL="protoc-3.20.0-linux-x86_64.zip" \
 && wget -q "https://github.com/protocolbuffers/protobuf/releases/download/v3.20.0/${PROTOC_TARBALL}" \
 && echo "${PROTOC_SHA256} ${PROTOC_TARBALL}" | sha256sum -c \
 && sudo unzip -d /usr/local "${PROTOC_TARBALL}" \
 && rm "${PROTOC_TARBALL}"

# Install Protoc-deg-go
RUN PROTOC_GEN_SHA256="0b2c257938a8cd9ba3506bbdbbaad45e51245b6f9e0743035ade7acf746c6be7" \
 && PROTOC_GEN_TARBALL="protoc-gen-go.v1.34.1.linux.amd64.tar.gz" \
 && wget -q "https://github.com/protocolbuffers/protobuf-go/releases/download/v1.34.1/${PROTOC_GEN_TARBALL}" \
 && echo "${PROTOC_GEN_SHA256} ${PROTOC_GEN_TARBALL}" | sha256sum -c \
 && sudo tar -C /usr/local/bin -xzf "${PROTOC_GEN_TARBALL}" \
 && rm "${PROTOC_GEN_TARBALL}"

# Install Go tools needed for the build
RUN go install github.com/go-bindata/go-bindata/v3/go-bindata@latest \
 && go install go.uber.org/mock/mockgen@v0.4.0


ENV PATH="/root/go/bin:${PATH}"

LABEL description="Build image for the Status-tablet Android APK."