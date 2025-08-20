FROM statusteam/nim-status-client-build:2.0.4-qt6.9.0

USER root

RUN apt-get update && apt-get install -yq --no-install-recommends --fix-missing \
    sudo \
    curl wget gnupg ca-certificates lsb-release python3-pip python3-venv \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y \
    docker-ce-cli docker-compose-plugin \
    mesa-common-dev libglu1-mesa-dev libpcsclite-dev \
    xvfb fluxbox libxft-dev xclip xsel nautilus \
    tesseract-ocr libzbar-dev libopenjp2-7 \
    ruby-dev ruby-bundler leiningen ghp-import git-lfs \
    librocksdb-dev libfuse2 \
    libpython3-dev \
    pcscd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

  # --- Squish Runner ---
ARG SQUISH_LICENSE_KEY="changeMeIfYouCare"

ENV SQUISH_RUNNER_VERSION=9.0.1
ENV SQUISH_QT_VERSION=6.9
ENV SQUISH_INSTALLER=squish-${SQUISH_RUNNER_VERSION}-qt69x-linux64.run
ENV SQUISH_INSTALLER_SHA256=4bad3059b3c24e1cbedea4ae261e0a1789ac0c4b74083c5216c8e4434354c53c
ENV SQUISH_INSTALL_DIR=/opt/squish-runner-${SQUISH_RUNNER_VERSION}-qt-${SQUISH_QT_VERSION}

RUN curl -L "https://status-misc.ams3.digitaloceanspaces.com/squish/${SQUISH_INSTALLER}" \
  -o /tmp/${SQUISH_INSTALLER} && \
  echo "${SQUISH_INSTALLER_SHA256}  /tmp/${SQUISH_INSTALLER}" | sha256sum -c - && \
  chmod +x /tmp/${SQUISH_INSTALLER} && \
  /tmp/${SQUISH_INSTALLER} unattended=1 python=3 targetdir=${SQUISH_INSTALL_DIR} licensekey=${SQUISH_LICENSE_KEY} && \
  rm /tmp/${SQUISH_INSTALLER}

USER jenkins

LABEL maintainer="marko@status.im"
LABEL source="https://github.com/status-im/status-desktop"
LABEL description="Build image for the Status Desktop e2e tests with Squish and Qt."