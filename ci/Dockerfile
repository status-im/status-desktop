FROM a12e/docker-qt:5.14-gcc_64

# $QT_PATH and $QT_PLATFORM are provided by the docker image
# $QT_PATH/$QT_VERSION/$QT_PLATFORM/bin is already prepended to $PATH
# However $QT_VERSION is not exposed to environment so set it here
ENV QT_VERSION="5.14.0"
ENV QTDIR="${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}"
ENV LD_LIBRARY_PATH="${QTDIR}/lib:${LD_LIBRARY_PATH}"
# $OPENSSL_PREFIX is provided by the docker image
ENV LIBRARY_PATH="${OPENSSL_PREFIX}/lib:${LIBRARY_PATH}"
ENV OPENSSL_ROOT_DIR="${OPENSSL_PREFIX}"

RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo apt update -yq \
 && sudo apt install -yq software-properties-common \
 && sudo add-apt-repository -y ppa:git-core/ppa \
 && sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test \
 && sudo apt update -yq \
 && sudo apt purge -yq gnupg \
 && sudo apt install -yq --fix-missing \
      jq git s3cmd gnupg2 ca-certificates \
      build-essential extra-cmake-modules gcc-9 g++-9 \
      libpcre3-dev libnss3 libxcomposite1 libxtst6 libpcsclite-dev \
      gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
      gstreamer1.0-plugins-ugly gstreamer1.0-libav \
      gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-pulseaudio

# C++17 is required
RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 \
 --slave /usr/bin/g++ g++ /usr/bin/g++-9

# CMake 3.16 or higher is required
RUN wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.sh \
 && chmod +x cmake-3.22.1-linux-x86_64.sh \
 && sudo mkdir /opt/cmake \
 && sudo sh cmake-3.22.1-linux-x86_64.sh --prefix=/opt/cmake --exclude-subdir --skip-license \
 && rm -f cmake-3.22.1-linux-x86_64.sh 
ENV PATH="/opt/cmake/bin:${PATH}"

# Fix LetsEncrypt X3 root certificate expliration
RUN sudo sed -i 's#\(mozilla/DST_Root_CA_X3.crt\)#!\1#' /etc/ca-certificates.conf \
 && sudo dpkg-reconfigure -fnoninteractive ca-certificates

# Installing Golang
RUN GOLANG_SHA256="9e5de37f9c49942c601b191ac5fba404b868bfc21d446d6960acc12283d6e5f2" \
 && GOLANG_TARBALL="go1.18.5.linux-amd64.tar.gz" \
 && wget -q "https://dl.google.com/go/${GOLANG_TARBALL}" \
 && echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c \
 && sudo tar -C /usr/local -xzf "${GOLANG_TARBALL}" \
 && rm "${GOLANG_TARBALL}" \
 && sudo ln -s /usr/local/go/bin/go /usr/local/bin

# Re-install Qt with QtWebEngine by adjusting QT_CI_PACKAGES
# The http_proxy=invalid is a fix for getting stuck on 'Welcome Page'
RUN sudo sed /tmp/build/install-qt.sh -i \
      -e 's/^QT_CI_PACKAGES=.*/export QT_CI_PACKAGES=qt.qt5.5140.gcc_64,qt.qt5.5140.qtwebengine,qt.qt5,qt.qt5.5140.qtlottie/' \
      -e '\#^/tmp/build/bin/extract-qt-installer.*#i export http_proxy=invalid' \
 && sudo -E /tmp/build/install-qt.sh

# Jenkins user needs a specific UID/GID to work
RUN sudo groupadd -g 1001 jenkins \
 && sudo useradd --create-home -u 1001 -g 1001 jenkins
USER jenkins
ENV HOME="/home/jenkins"

LABEL maintainer="jakub@status.im"
LABEL source="https://github.com/status-im/status-desktop"
LABEL description="Build image for the Status Desktop client written in Nim."
