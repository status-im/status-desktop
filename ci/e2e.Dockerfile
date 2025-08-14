FROM statusteam/nim-status-client-build:2.0.2-qt6.9.0

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
    cmake protoc-gen-go \
    mesa-common-dev libglu1-mesa-dev libpcsclite-dev \
    xvfb fluxbox libxft-dev xclip xsel nautilus \
    tesseract-ocr libzbar-dev libopenjp2-7 \
    ruby-dev ruby-bundler leiningen ghp-import git-lfs \
    librocksdb-dev libfuse2 \
    libpython3-dev \
    pcscd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- mdbook ---
ENV MDBOOK_VERSION=v0.4.12 \
    MDBOOK_MD5=b73dd9d9598e3350b9d220e89f210c63
RUN curl -L "https://github.com/rust-lang/mdBook/releases/download/${MDBOOK_VERSION}/mdbook-${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
  -o /tmp/mdbook.tar.gz && \
  echo "${MDBOOK_MD5}  /tmp/mdbook.tar.gz" | md5sum -c - && \
  tar -xzf /tmp/mdbook.tar.gz -C /usr/local/bin && rm /tmp/mdbook.tar.gz

# --- github-release ---
ENV GITHUB_RELEASE_VERSION=v0.10.0 \
    GITHUB_RELEASE_BZ2_NAME=linux-amd64-github-release.bz2 \
    GITHUB_RELEASE_BZ2_SHA256=b360af98188c5988314d672bb604efd1e99daae3abfb64d04051ee17c77f84b6
RUN curl -L "https://github.com/github-release/github-release/releases/download/${GITHUB_RELEASE_VERSION}/${GITHUB_RELEASE_BZ2_NAME}" \
  -o /tmp/github-release.bz2 && \
  echo "${GITHUB_RELEASE_BZ2_SHA256}  /tmp/github-release.bz2" | sha256sum -c - && \
  bunzip2 /tmp/github-release.bz2 && \
  mv /tmp/github-release /usr/bin/github-release && chmod +x /usr/bin/github-release

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