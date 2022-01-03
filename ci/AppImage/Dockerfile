ARG QT_VERSION=5.15.2

# QT Installation Image --------------------------------------------------------
FROM ubuntu:18.04 AS qt-install

ARG QT_VERSION

RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends \
    sudo python3 python3-pip git \
    && apt-get -qq clean

RUN python3 -m pip install setuptools

RUN chmod -R 777 /opt

RUN mkdir -p /opt/qt
RUN chmod -R 777 /opt/qt


ENV QT_VERSION=$QT_VERSION \
    QT_PATH=/opt/qt

RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user


COPY scripts/install-qt.sh /home/user/
COPY scripts/aqt.ini /home/user/
RUN chown user:user /home/user/install-qt.sh
RUN chmod a+x /home/user/install-qt.sh

USER user
WORKDIR /home/user

ENV HOME /home/user
ENV QT_VERSION=$QT_VERSION

# Re-install Qt with QtWebEngine by adjusting QT_CI_PACKAGES
# The http_proxy=invalid is a fix for getting stuck on 'Welcome Page'
RUN sudo sed /home/user/install-qt.sh -i \
      -e 's/^QT_CI_PACKAGES=.*/export QT_CI_PACKAGES=qt.qt5.5152.gcc_64,qt.qt5.5152.qtwebengine,qt.qt5/' \
      -e '\#^/tmp/build/bin/extract-qt-installer.*#i export http_proxy=invalid' \
 && sudo -E /home/user/install-qt.sh



# Build Image ------------------------------------------------------------------
FROM ubuntu:18.04

ARG OPENSSL_VERSION=1.1.1d
ARG LINUXDEPLOYQT_VERSION=continuous
ARG QT_VERSION


# Adapted from a12e/docker-qt by Aurélien Brooke

ENV DEBIAN_FRONTEND=noninteractive \
    OPENSSL_PREFIX=/usr/local/ssl \
    QMAKESPEC=linux-g++ \
    QT_PATH=/opt/qt \
    QT_PLATFORM=gcc_64 \
    QT_VERSION=$QT_VERSION

ENV \
    PATH=${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}/bin:${OPENSSL_PREFIX}/bin:$PATH


RUN apt update -yq && apt install -yq software-properties-common \
&& add-apt-repository -y ppa:git-core/ppa \
 && apt update -yq && apt full-upgrade -yq && apt install -yq --no-install-recommends --fix-missing  \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    build-essential \
    pkg-config \
    libgl1-mesa-dev \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libdbus-1-3 \
    libz-dev \
    fuse \
    file \
    libxkbcommon-x11-0 \
    wget \
    make libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev \
    libgstreamer-plugins-base1.0-0 \
    cmake s3cmd libpcre3-dev libnss3 libxcomposite1 libxtst6 jq \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \ 
    gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-alsa libpulse-mainloop-glib0 \
    gstreamer1.0-pulseaudio libxrandr2 libxcursor1 libxi6 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-render-util0 libxcb-render0 libxcb-xinerama0 \
    && apt-get -qq clean

COPY scripts/* /tmp/build/
RUN chmod a+x /tmp/build/*.sh

# Download and install OpenSSL
RUN /tmp/build/install-openssl-linux.sh

# Download & install linuxdeployqt
RUN /tmp/build/install-linuxdeployqt.sh

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales \
# Add group & user
    && groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

# Copy QT toolchain
RUN chmod -R 777 /opt && mkdir -p /opt/qt/$QT_VERSION
COPY --from=qt-install /opt/qt/$QT_VERSION /opt/qt/$QT_VERSION/.

USER user
WORKDIR /home/user
ENV HOME /home/user


# $QT_PATH/$QT_VERSION/$QT_PLATFORM/bin is already prepended to $PATH
ENV QTDIR="${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}"
ENV LD_LIBRARY_PATH="${QTDIR}/lib:${LD_LIBRARY_PATH}"
# $OPENSSL_PREFIX is provided by the docker image
ENV LIBRARY_PATH="${OPENSSL_PREFIX}/lib:${LIBRARY_PATH}"

RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo apt update -yq \
 && sudo apt install -yq software-properties-common \
 && sudo add-apt-repository -y ppa:git-core/ppa \
 && sudo apt update -yq \
 && sudo apt purge -yq gnupg \
 && sudo apt install -yq --fix-missing \
      build-essential cmake jq git s3cmd gnupg2 \
      libpcre3-dev libnss3 libxcomposite1 libxtst6 \
      gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
      gstreamer1.0-plugins-ugly gstreamer1.0-libav \
      gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-pulseaudio \
      libpcsclite-dev

# Fix LetsEncrypt X3 root certificate expliration
RUN sudo sed -i 's#\(mozilla/DST_Root_CA_X3.crt\)#!\1#' /etc/ca-certificates.conf \
 && sudo dpkg-reconfigure -fnoninteractive ca-certificates

# Installing Golang
RUN GOLANG_SHA256="d2c095c95f63c2a3ef961000e0ecb9d81d5c68b6ece176e2a8a2db82dc02931c" \
 && GOLANG_TARBALL="go1.16.9.linux-amd64.tar.gz" \
 && curl -L "https://dl.google.com/go/${GOLANG_TARBALL}" --output $GOLANG_TARBALL \
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