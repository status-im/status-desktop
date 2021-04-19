# Description

This document describes how the signing of Windows application was configured.

# Certificates

The signing uses two types of Certificates:

* Self-Signed Code Signing certificate for development and PR builds
* [DigiCert](https://www.digicert.com/) standard release Code Signing certificate

## Self-Signed Certificate

This certificate was created on using the following PowerShell commands:
```Powershell
$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname status.im -Subject "Dev Status Cert" -type CodeSigning
$pwd = ConvertTo-SecureString -String 'SUPER-SECRET-PASSWORD -Force -AsPlainText
Export-PfxCertificate -cert $cert -FilePath Status-Destkop-SelfSigned.pfx -Password $pwd -CryptoAlgorithmOption AES256_SHA256
```
Which should create a `Status-Destkop-SelfSigned.pfx` file encrypted with the provided password.

Keep in mind that the `-type CodeSigning` flag is important.

For more details see [this article](http://woshub.com/how-to-create-self-signed-certificate-with-powershell/).

## DigiCert Certificate

This certificate is was purchased on 23rd of September 2020 from [DigiCert.com](https://www.digicert.com/).
It is a `Microsoft Authenticode` certificate and should be valid for 2 years.

# Continuous Integration

The Jenkins setup which makes use of these certificates makes them available under different job folder under different credential names. This way we can sign non-release builds while not making them appear to a user as a release build. The self-signed certificate should trigger windows warnings when starting the application.

The way this works is certificates are split across two Jenkins job folders:

* [status-desktop/platforms](https://ci.status.im/job/status-desktop/job/platforms/credentials/store/folder/domain/_/) - Release and Nightly builds.
* [status-desktop/branches](https://ci.status.im/job/status-desktop/job/branches/credentials/store/folder/domain/_/) - Branch and PR builds.

These folders contain different certificates, which provides another layer of security in case someone submits a malicious PR which attempts to extract valuable secrets. In this setup the only thing they might possibly extract would be the self-signed certificate and its password.

The exact access to the credentials is hidden from malicious eyes that can inspect `Jenkinsfile`s in this repo, and instead are implemented in our private [`status-jenkins-lib`](https://github.com/status-im/status-jenkins-lib) repository under `vars/windows.groovy`.

# Known Issues

#### `Error: Store::ImportCertObject() failed. (-2146893808/0x80090010)`

This error would appears when trying to sign binaries with `signtool.exe` when Jenkins was accessing the Windows CI slave via SSH.

The solution was to switch the setup to deploy the [Jenkins Remoting Agent Service](https://www.jenkins.io/projects/remoting/) using the [WinSW](https://github.com/winsw/winsw) utility to run it as a Windows service.

#### `CertEnroll::CX509Enrollment::_CreateRequest: Access denied. 0x80090010 (-2146893808 NTE_PERM)`

You cannot create a self-signed certificate in a PowerShell instance without elevated privilidges. You might have to run the shell as system administrator.

# Links

* https://github.com/status-im/infra-ci/issues/28
* https://github.com/status-im/status-desktop/issues/2170
