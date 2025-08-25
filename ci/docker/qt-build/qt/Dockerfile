FROM statusteam/qt-dev-base:noble-17-35-27.2.12479018
ENTRYPOINT ["/bin/bash", "-l", "-c"]
WORKDIR /root

ARG QTVER

COPY qt_export/Qt-android-$QTVER.tar.xz /root/
COPY qt_export/Qt-amd64-$QTVER.tar.xz* /root/

# Extract Qt Android
RUN \
    mkdir -p /opt/qt/$QTVER && \
    cd /opt/qt/$QTVER && \
    tar xvfp /root/Qt-android-$QTVER.tar.xz && \
    rm /root/Qt-android-$QTVER.tar.xz

RUN \
    if [ -f /root/Qt-amd64-$QTVER.tar.xz ]; then \
        cd /opt/qt/$QTVER && \
        tar xvfp /root/Qt-amd64-$QTVER.tar.xz && \
        rm /root/Qt-amd64-$QTVER.tar.xz; \
    fi

RUN \
    apt-get -y autoremove \
 && apt-get -y autoclean \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

# Set paths for host Qt (used for Android cross-compilation)
ENV PATH="${PATH}:/opt/qt/$QTVER/gcc_64/bin:/opt/qt/$QTVER/gcc_64/libexec"
ENV QT_HOST_PATH="/opt/qt/$QTVER/gcc_64/"
ENV QT_PLUGIN_PATH="/opt/qt/$QTVER/gcc_64/plugins"
