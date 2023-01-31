FROM ubuntu:18.04
RUN apt-get update && \
apt-get install --no-install-recommends -y apt-transport-https ca-certificates gnupg software-properties-common wget && \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
apt-get update && \
apt-get install --no-install-recommends -y cmake g++ make qt5-default git lcov curl qtdeclarative5-dev qtbase5-dev qtquickcontrols2-5-dev xvfb ninja-build qml-module-qtquick-controls
