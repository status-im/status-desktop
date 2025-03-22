#!/usr/bin/env bash

set -e pipefail

rm -rf "${APP_DIR}"

mkdir -p \
  "${APP_DIR}/usr/bin" \
  "${APP_DIR}/usr/lib" \
  "${APP_DIR}/usr/qml" \
  "${APP_DIR}/usr/i18n" \
  "${APP_DIR}/usr/plugins/platforminputcontexts" \
  "${APP_DIR}/etc/reader.conf.d" \
  "${APP_DIR}/usr/lib/pcsc/drivers" \
  "${APP_DIR}/usr/sbin"


cp bin/nim_status_client "${APP_DIR}/usr/bin"
cp bin/StatusQ/* "${APP_DIR}/usr/lib"
cp nim-status.desktop "${APP_DIR}/."
cp status.png "${APP_DIR}/status.png"
cp status.png "${APP_DIR}/usr/"
cp -R resources.rcc "${APP_DIR}/usr/"
cp bin/i18n/* "${APP_DIR}/usr/i18n"
cp vendor/status-go/build/bin/libstatus.so "${APP_DIR}/usr/lib/"
cp vendor/status-go/build/bin/libstatus.so.0 "${APP_DIR}/usr/lib/"
cp "${STATUSKEYCARDGO}" "${APP_DIR}/usr/lib/"
cp "${FCITX5_QT}" "${APP_DIR}/usr/plugins/platforminputcontexts/"

echo "Bundling pcsc-lite 2.2.3..."
cp -L /usr/local/lib/x86_64-linux-gnu/libpcsclite.so* "${APP_DIR}/usr/lib/"
cp -L /usr/local/lib/x86_64-linux-gnu/libpcsclite_real.so* "${APP_DIR}/usr/lib/"
cp -L /usr/local/lib/x86_64-linux-gnu/pkgconfig/libpcsclite.pc "${APP_DIR}/usr/lib/"

chmod 755 "${APP_DIR}/usr/lib/libpcsclite.so"*
chmod 755 "${APP_DIR}/usr/lib/libpcsclite_real.so"*
chmod 755 "${APP_DIR}/usr/lib/libpcsclite.pc"

if [ -d "/usr/lib/pcsc/drivers" ]; then
  cp -r /usr/lib/pcsc/drivers/* "${APP_DIR}/usr/lib/pcsc/drivers/" || true
fi

mkdir -p "${APP_DIR}/etc/udev/rules.d"
if [ -f "/usr/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist" ]; then
  cp /usr/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist "${APP_DIR}/usr/lib/pcsc/drivers/" || true
fi

cat > "${APP_DIR}/etc/reader.conf.d/000-bundled-pcsc.conf" << EOF
# Use bundled pcsc-lite drivers
PCSC_DRIVERS_DIR=\$APPDIR/usr/lib/pcsc/drivers
EOF

echo "Bundling pscd..."
cp -L "/usr/local/sbin/pcscd"* "${APP_DIR}/usr/sbin/"
chmod 755 "${APP_DIR}/usr/sbin/pcscd"*
mkdir -p "${APP_DIR}/run/pcscd"

if [ -f "/usr/lib/x86_64-linux-gnu/libusb-1.0.so.0" ]; then
  cp -L /usr/lib/x86_64-linux-gnu/libusb-1.0.so.0* "${APP_DIR}/usr/lib/" || true
fi
if [ -f "/lib/x86_64-linux-gnu/libusb-1.0.so.0" ]; then
  cp -L /lib/x86_64-linux-gnu/libusb-1.0.so.0* "${APP_DIR}/usr/lib/" || true
fi

# Copy dependencies, which linuxdeployqt can't manage from nix store or system (FHS)
if [[ -z "${IN_NIX_SHELL}" ]]; then
	cp -r /usr/lib/x86_64-linux-gnu/nss "${APP_DIR}/usr/lib/"
	cp -P /usr/lib/x86_64-linux-gnu/libgst* "${APP_DIR}/usr/lib/"
	cp -r /usr/lib/x86_64-linux-gnu/gstreamer-1.0 "${APP_DIR}/usr/lib/"
	cp -r /usr/lib/x86_64-linux-gnu/gstreamer1.0 "${APP_DIR}/usr/lib/"
else
	mkdir -p "${APP_DIR}"/usr/lib/{gstreamer1.0,gstreamer-1.0,nss}
	mkdir -p "${APP_DIR}"/usr/libexec

	echo "${GST_PLUGIN_SYSTEM_PATH_1_0}" | tr ':' '\n' | sort -u | xargs -I {} find {} -name "*.so" | xargs -I {} cp {} "${APP_DIR}/usr/lib/gstreamer-1.0/"
	cp -r "${GSTREAMER_PATH}/libexec/gstreamer-1.0" "${APP_DIR}/usr/lib/gstreamer1.0/"
	cp "${LIBKRB5_PATH}/lib/libcom_err.so.3" "${APP_DIR}/usr/lib/libcom_err.so.3"
	cp "${NSS_PATH}"/lib/{libfreebl3,libfreeblpriv3,libnssckbi,libnssdbm3,libsoftokn3}.{chk,so} "${APP_DIR}/usr/lib/nss/" || true
	cp "${QTWEBENGINE_PATH}/libexec/QtWebEngineProcess" "${APP_DIR}/usr/libexec/QtWebEngineProcess"
	cp "${QTWEBENGINE_PATH}"/resources/* "${APP_DIR}/usr/libexec/"
	cp -r "${QTWEBENGINE_PATH}/translations/qtwebengine_locales" "${APP_DIR}/usr/libexec/"

	chmod -R u+w "${APP_DIR}/usr"
fi
