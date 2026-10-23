# Share-intake instrumentation tests

## `ShareIntakeSecurityTest`

Regression guard for the share-intake stream vetting in
`StatusQtActivity.handleShareIntake`: every `EXTRA_STREAM` is opened as Status
itself, so without vetting a zero-permission app could send `ACTION_SEND` with a
`file:///data/user/0/app.status.mobile/...` URI (or a `content://` URI on
Status's own `${applicationId}.qtprovider` authority) and have private
keystore/DB/log content staged as a sendable image.

Contract under test: **only foreign `content://` streams are accepted**.
`fileSchemeStreamIsRejected` and `ownFileProviderAuthorityIsRejected` pin the
two rejection paths; `foreignContentStreamIsAccepted` guards against an
over-broad fix.

## `ShareImageTranscoderTest`

Image normalization at share intake (`ShareImageTranscoder.copyNormalized`):
HEIC/HEIF is re-encoded as JPEG and JPEGs over 2048 px are downscaled, as the
iOS share extension does, because neither the composer's image validator nor
status-go decodes HEIC. Uses the `landscape-3000x2000.heic` fixture from the
test APK's assets; the JPEG/PNG inputs are generated at runtime.

## Running

Needs a booted emulator/device and the app built with the Qt Android toolchain
(`QT_ANDROID_DIR`, status-go libs, NDK). Gradle runs from the androiddeployqt
output dir, so go through the mobile build:

```bash
GRADLE_TARGETS="assembleDebug connectedDebugAndroidTest" make mobile-build
```

Neither test boots Qt — they call static seams (`extractStreamUris` by
reflection, `ShareImageTranscoder` directly) — but they run under
instrumentation because `android.net.Uri` parsing, the `PackageManager` provider
lookup and `ImageDecoder`'s HEIF support need the real framework.
