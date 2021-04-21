FROM a12e/docker-qt:5.14-gcc_64

# $QT_PATH and $QT_PLATFORM are provided by the docker image
# $QT_PATH/$QT_VERSION/$QT_PLATFORM/bin is already prepended to $PATH
# However $QT_VERSION is not exposed to environment so set it here
ENV QT_VERSION="5.14.0"
ENV QTDIR="${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}"
ENV LD_LIBRARY_PATH="${QTDIR}/lib:${LD_LIBRARY_PATH}"
# $OPENSSL_PREFIX is provided by the docker image
ENV LIBRARY_PATH="${OPENSSL_PREFIX}/lib:${LIBRARY_PATH}"

RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo apt update -yq \
 && sudo apt install -yq software-properties-common \
 && sudo add-apt-repository -y ppa:git-core/ppa \
 && sudo apt update -yq \
 && sudo apt install -yq --fix-missing \
      build-essential cmake git s3cmd libpcre3-dev libnss3 libxcomposite1 libxtst6 jq gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-pulseaudio

# Installing Golang
RUN GOLANG_SHA256="aed845e4185a0b2a3c3d5e1d0a35491702c55889192bb9c30e67a3de6849c067" \
 && GOLANG_TARBALL="go1.14.4.linux-amd64.tar.gz" \
 && wget -q "https://dl.google.com/go/${GOLANG_TARBALL}" \
 && echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c \
 && sudo tar -C /usr/local -xzf "${GOLANG_TARBALL}" \
 && rm "${GOLANG_TARBALL}" \
 && sudo ln -s /usr/local/go/bin/go /usr/local/bin

# Re-install Qt with QtWebEngine by adjusting QT_CI_PACKAGES
# The http_proxy=invalid is a fix for getting stuck on 'Welcome Page'
RUN sudo sed /tmp/build/install-qt.sh -i \
      -e 's/^QT_CI_PACKAGES=.*/export QT_CI_PACKAGES=qt.qt5.5140.gcc_64,qt.qt5.5140.qtwebengine,qt.qt5/' \
      -e '\#^/tmp/build/bin/extract-qt-installer.*#i export http_proxy=invalid' \
 && sudo -E /tmp/build/install-qt.sh

# Jenkins user needs a specific UID/GID to work
RUN sudo groupadd -g 1001 jenkins \
 && sudo useradd --create-home -u 1001 -g 1001 jenkins
USER jenkins
ENV HOME="/home/jenkins"

LABEL maintainer="jakub@status.im"
LABEL source="https://github.com/status-im/nim-status-client"
LABEL description="Build image for the Status Desktop client written in Nim."
