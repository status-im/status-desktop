FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN    apt update -yq \
    && apt install -yq --no-install-recommends --fix-missing  \
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
        pbuilder ubuntu-dev-tools apt-file \
        qtbase5-dev qtdeclarative5-dev qml-module-qt-labs-platform qtquickcontrols2-5-dev libqt5svg5-dev  \
        libqt5gui5 libqt5core5a libqt5network5 libqt5qml5 libqt5quick5 libqt5svg5 libqt5webengine5 libqt5webenginecore5 libqt5quickcontrols2-5 libqt5widgets5 \
    && apt-get -qq clean

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales \
# Add group & user
    && groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user
ENV HOME /home/user

# Installing Golang
RUN GOLANG_SHA256="aed845e4185a0b2a3c3d5e1d0a35491702c55889192bb9c30e67a3de6849c067" \
 && GOLANG_TARBALL="go1.14.4.linux-amd64.tar.gz" \
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

LABEL maintainer="richard@status.im"
LABEL source="https://github.com/status-im/status-desktop"
LABEL description="Build image for creating a .deb package for the Status Desktop client."
