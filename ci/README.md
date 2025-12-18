# Description

These `Jenkinsfile`s are used to run CI jobs in Jenkins. You can find them here:
https://ci.status.im/job/nim-status-client/

# Builds

## Linux

In order to build the Linux version of the application we use the `ubuntu:20.04` Docker image where we install the Qt 5.15.2 provided by [aqt](https://github.com/miurahr/aqtinstall), linuxdeployqt provided by https://github.com/probonopd/linuxdeployqt and other dependencies (go, cmake, gcc etc.). We're using Ubuntu 20.04 to ensure glibc compatibility with the oldest still-supported LTS release and to comply with linuxdeployqt requirements.

The image is built with [`Dockerfile`](./Dockerfile) using:
```
docker build -t statusteam/nim-status-client-build:latest .
```
And pushed to: https://hub.docker.com/r/statusteam/nim-status-client-build

## MacOS

The MacOS builds are run on MacOS hosts and expect Command Line Toold and XCode to be installed, as well as QT being available under `/usr/local/qt`.

It also expects the presence of the following credentials:

* `macos-keychain-identity` - ID of used signing certificate.
* `macos-keychain-pass` - Password to unlock the keychain.
* `macos-keychain-file` - Keychain file with the MacOS signing certificate.

You can read about how to create such a keychain [here](https://github.com/status-im/infra-docs/blob/master/articles/macos_signing_keychain.md).

## iOS

iOS builds use **fastlane** with **match** for code signing management. This provides:
- Automatic certificate and profile management
- Separate signing for PR vs release builds

### Bundle Identifiers

| Build Type | Bundle ID              | Fastlane Lane |
|------------|------------------------|---------------|
| PR builds  | `app.status.mobile.pr` | `pr`          |
| Release    | `app.status.mobile`    | `release`     |

### Certificate Types

| Build Type | Certificate Type   | Match Type  | Purpose                       |
|------------|--------------------|-------------|-------------------------------|
| PR builds  | Apple Distribution | `adhoc`     | Testing on registered devices |
| Release    | Apple Distribution | `appstore`  | App Store / TestFlight        |

### Fastlane Files

The `fastlane` configuration is located in `mobile/fastlane/`:

| File        | Purpose                                      |
|-------------|----------------------------------------------|
| `Fastfile`  | Defines signing lanes (`pr`, `release`)      |
| `Matchfile` | Configures match for certificate management  |
| `Appfile`   | App identifiers and team configuration       |
| `Gemfile`   | Ruby dependencies                            |


### Local Development

To run `fastlane` locally for testing:

```bash
cd mobile/fastlane
nix --extra-experimental-features 'nix-command flakes' develop
bundle install

# Run a specific lane
bundle exec fastlane ios pr
bundle exec fastlane ios release
```

### Revoking/Rotating Certificates

If a certificate is compromised or revoked:

```bash
cd mobile/fastlane

# Nuke existing certificates (warning!! watch what you nuke)
bundle exec fastlane match nuke development
bundle exec fastlane match nuke distribution

# Regenerate
bundle exec fastlane match development --app_identifier "app.status.mobile.pr"
bundle exec fastlane match appstore --app_identifier "app.status.mobile"
```

