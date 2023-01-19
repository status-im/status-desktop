ARG QT_VERSION=5.15.2

# QT Installation Image --------------------------------------------------------
FROM ubuntu:18.04 AS qt-install

ARG QT_VERSION

RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends sudo python3 python3-pip \
 && apt-get -qq clean

RUN chmod -R 777 /opt

# Install QT
RUN python3 -m pip install setuptools \
 && python3 -m pip install -U pip \
 && python3 -m pip install aqtinstall \
 && python3 -m aqt install --output /opt/qt ${QT_VERSION} linux desktop -m qtwebengine

# Build Image ------------------------------------------------------------------
FROM ubuntu:18.04

ARG LINUXDEPLOYQT_VERSION=continuous
ARG QT_VERSION

# Adapted from a12e/docker-qt by Aurélien Brooke

ENV DEBIAN_FRONTEND=noninteractive \
    QMAKESPEC=linux-g++ \
    QT_PATH=/opt/qt \
    QT_PLATFORM=gcc_64 \
    QT_VERSION=$QT_VERSION
    
ENV PATH=${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}/bin:$PATH \
    QTDIR=${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}

ENV LD_LIBRARY_PATH=${QTDIR}/lib:${LD_LIBRARY_PATH}

# Install dependencies
RUN apt update -yq && apt install -yq software-properties-common \
 && add-apt-repository -y ppa:git-core/ppa \
 && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
 && apt update -yq && apt full-upgrade -yq && apt install -yq --no-install-recommends --fix-missing  \
    git openssh-client ca-certificates locales sudo curl build-essential pkg-config libgl1-mesa-dev libsm6 libice6 libxext6 libxrender1 \
    libfontconfig1 libdbus-1-3 libz-dev fuse file libxkbcommon-dev libxkbcommon-x11-dev wget make libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev libgstreamer-plugins-base1.0-0 libpcsclite-dev cmake extra-cmake-modules s3cmd libpcre3-dev libnss3 libxcomposite1 libxtst6 jq \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-alsa libpulse-mainloop-glib0 \
    gstreamer1.0-pulseaudio libxrandr2 libxcursor1 libxi6 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-render0 libxcb-xinerama0 gnupg2 gcc-9 g++-9 \
 &&  update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
 && apt-get -qq clean

# Install linuxdeployqt
RUN mkdir -p /usr/local/bin \
 && curl -Lo/usr/local/bin/linuxdeployqt "https://github.com/probonopd/linuxdeployqt/releases/download/$LINUXDEPLOYQT_VERSION/linuxdeployqt-$LINUXDEPLOYQT_VERSION-x86_64.AppImage" \
 && chmod a+x /usr/local/bin/linuxdeployqt

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Copy QT toolchain
RUN chmod -R 777 /opt && mkdir -p /opt/qt/$QT_VERSION
COPY --from=qt-install /opt/qt/$QT_VERSION /opt/qt/$QT_VERSION/.

# Fix LetsEncrypt X3 root certificate expliration
RUN sudo sed -i 's#\(mozilla/DST_Root_CA_X3.crt\)#!\1#' /etc/ca-certificates.conf \
 && sudo dpkg-reconfigure -fnoninteractive ca-certificates

# CMake 3.16 or higher is required
RUN wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.sh \
 && chmod +x cmake-3.22.1-linux-x86_64.sh \
 && sudo mkdir /opt/cmake \
 && sudo sh cmake-3.22.1-linux-x86_64.sh --prefix=/opt/cmake --exclude-subdir --skip-license \
 && rm -f cmake-3.22.1-linux-x86_64.sh 
ENV PATH="/opt/cmake/bin:${PATH}"

# Installing Golang
RUN GOLANG_SHA256="36519702ae2fd573c9869461990ae550c8c0d955cd28d2827a6b159fda81ff95" \
 && GOLANG_TARBALL="go1.19.5.linux-amd64.tar.gz" \
 && wget -q "https://dl.google.com/go/${GOLANG_TARBALL}" \
 && echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c \
 && sudo tar -C /usr/local -xzf "${GOLANG_TARBALL}" \
 && rm "${GOLANG_TARBALL}" \
 && sudo ln -s /usr/local/go/bin/go /usr/local/bin

# Jenkins user needs a specific UID/GID to work
RUN sudo groupadd -g 1001 jenkins \
 && sudo useradd --create-home -u 1001 -g 1001 jenkins
USER jenkins
ENV HOME="/home/jenkins"

LABEL maintainer="jakub@status.im"
LABEL source="https://github.com/status-im/status-desktop"
LABEL description="Build image for the Status Desktop client written in Nim."