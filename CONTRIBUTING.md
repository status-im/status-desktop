# Contributing to Status Desktop

## Table of Contents
- [🛠️ Developing](#️-developing)
- [🪲 Desktop Status App Community Testing](#-desktop-status-app-community-testing)
  - [Important Backup Information](#1-important)
  - [Download the Release Candidate Build](#2-download-the-release-candidate-build)
  - [Install the Release Candidate](#3-install-the-release-candidate)
  - [Create a Test Profile First](#4-create-a-test-profile-first)
  - [Test Regular Usage Flows](#5-test-regular-usage-flows)
  - [Collaborate on Testing](#6-collaborate-on-testing-release-candidates)
  - [Reporting Bugs](#7-reporting-bugs)
  - [Recovering Your Real Status Account](#8-recovering-your-real-status-account)

## 🛠️ Developing

- [Building from Source](https://zealous-polka-dc7.notion.site/Building-ca1db4fb3baf4f15bab8da717832b743?pvs=74)
- Check our [Architecture Docs](docs/architecture.md).
- Read our [QML Architecture Guidelines](guidelines/QML_ARCHITECTURE_GUIDE.md).
- Check out [good first issues](https://github.com/status-im/status-desktop/contribute) to get involved.
- Join the [#feedback-desktop](https://status.app/cc/G-EAAORobqgnsUPSVCLaSJr855iXTIdQiY1Q0ckBe8dWWEBpUAs9s8DTjWEpvsmpE83Izx1JWQuZrWWKUoxiXCwdtB-wPBzyvv_n9a0F61xTaPZE7BEJDC7Ly_WcmQ4tHRAKnPfXE_JUtEX_3NhnXQN0eh4ue0D77dWvaDpDrSi0U0CaGLZ-pqD_iV0z9RMFE2LKulDZdwL40etJ8lxjyTFoxS0lUhdWKinIOk8qBmJJpCmsqMrSklEU#zQ3shZeEJqTC1xhGUjxuS4rtHSrhJ8vUYp64v6qWkLpvdy9L9) channel on Status.

## 🪲 Desktop Status App Community Testing

*Disclaimer*

*In addition to the Status Software Terms of Use and Status Software Privacy Policy, you agree to the following when you use this test build of Status Software (“Status Software Release Candidate Build”):*

*Status Software Release Candidate Build is provided to you for evaluation purposes only. By using this build, you acknowledge that, among other issues with test builds, it may contain bugs, incomplete or other test features or have unexpected behaviours. You use Status Software Release Candidate Build at your own risk. We are not responsible for any losses or damages you might incur or suffer from using Status Software Release Candidate Build. Please report any potential issues and feedback you might have to help us improve Status Software.*


### **🛠️ Testing Instructions for Status Release Candidate Build**

#### 1. Important!

If you plan to test using your **existing/real** Status profile, **make sure you have your recovery phrase backed up** before upgrading to a release candidate version.

#### 2. Download the Release Candidate Build

Get the latest release candidate build (look for versions with “**<code>-rc"</code>** in the name) from: \
 👉[ https://github.com/status-im/status-desktop/releases](https://github.com/status-im/status-desktop/releases).
 
Refer to the table below to see which file you should use for your operating system.
* **Known issues:** users on **macOS with Intel chips** should **NOT **upgrade to version v2.33 or higher to test release candidate builds due to a critical bug causing app crashes in this release (more details: [#15730](https://github.com/status-im/status-desktop/issues/15730)). The team is actively working on a fix for upcoming releases.

<table>
  <tr>
   <td>
<strong>Example of File Name</strong>
   </td>
   <td><strong>Operating System</strong>
   </td>
  </tr>
  <tr>
   <td>StatusIm-Desktop-2.34.0-rc.4-0d22be-x86_64.7z
   </td>
   <td>Windows (portable)
   </td>
  </tr>
  <tr>
   <td>StatusIm-Desktop-2.34.0-rc.4-0d22be-x86_64.exe
   </td>
   <td>Windows (installer)
   </td>
  </tr>
  <tr>
   <td>StatusIm-Desktop-2.34.0-rc.4-dirty-0d22be-aarch64.dmg
   </td>
   <td>macOS (Apple Silicon / arm)
   </td>
  </tr>
  <tr>
   <td>StatusIm-Desktop-2.34.0-rc.4-dirty-0d22be-x86_64.nix.tar.gz.asc
   </td>
   <td>Linux (Nix, signature file)
   </td>
  </tr>
  <tr>
   <td>StatusIm-Desktop-2.34.0-rc.4-dirty-0d22be-x86_64.tar.gz
   </td>
   <td>Linux (general, tarball)
   </td>
  </tr>
  <tr>
   <td>StatusIm-Desktop-2.34.0-rc.4-dirty-0d22be-x86_64.tar.gz.asc
   </td>
   <td>Linux (general, signature file)
   </td>
  </tr>
</table>



#### 3. Install the Release Candidate

Follow the [instructions here](README.md#-download--install) to know how to install. 

The test build will be installed **over your current Desktop Status App**, replacing the existing installation. 

    ⚠️ Note: upgrading to a Release Candidate (RC) build may damage your current app state or cause unexpected behavior. Please note that while restoring your profile using a Recovery Phrase will recover all your wallets and funds (i.e. your funds will not be affected), some user data may not be recovered. Proceed with caution and ensure you read the disclaimer above before installing.

#### 4. Create a Test Profile First

Before using your real Status profile for testing:

  * Create a **test profile**
  * **Put your app into Debug mode:** Settings >>> Advanced >>> Debug (toggle it on) so the App starts generating logs (in case you need to attach them when reporting bugs).
  * Try out the main features you regularly use
  * If everything works as expected, **log out** and then **log in with your real Status profile** to continue testing.

#### 5. Test Regular Usage Flows

Use the app as you normally would.

* If you're new to the Status app or app testing, refer to the [Status Help Documentation Center](https://status.app/help) for guidance on how the app features work so you can test them effectively.
* If you're already familiar with the Status app and app testing, it's also helpful to specifically test the following features:
  * Onboarding and login
  * Wallet
  * Chat
  * Profile showcase
  * Communities
  * Community Portal
  * Settings
  * Notification center
  * Market center
  * etc.

#### 6. Collaborate on Testing Release Candidates:

If you have questions, need more information, or want to stay in the loop and collaborate on Release Candidate testing, please use the [#feedback-desktop channel](https://status.app/cc/G-EAAORqbagnsUXSq0S0kTT5vWNeMtMJlRbohIpODtg7tsICSoNa6JkFnm4MS_FNTp1oRn7uSMpayGwtU5RiFONi6aD9gOXhkPf9369PLVjnmkKzJ2KPSGBwWV6u58x0aOmAUOC8v56Qp6It-ufGPusaoNPzcNkD2m-vfkXTGWpFoZ0C0sSw9TMF_U_smqmfKJgQU9aFyn4TwI9eT5LnGkuOQStuKZG6sFJJQdZ5UjEQSyJNYUVVlpaMogA=#zQ3shZeEJqTC1xhGUjxuS4rtHSrhJ8vUYp64v6qWkLpvdy9L9 ) in the Status App.

#### 7. Reporting Bugs

If you encounter what seems to be a bug:

  * First, **search** the GitHub issues page to check if it's already reported: \
🔎[ https://github.com/status-im/status-desktop/issues \
](https://github.com/status-im/status-desktop/issues)
  * If it’s not listed, please **open a new issue** using the bug report template: \
🐛[ https://github.com/status-im/status-desktop/issues/new?template=bug.md](https://github.com/status-im/status-desktop/issues/new?template=bug.md)
      * To help us further, provide the logs from the app along with the issue
      * You can find the logs in the following locations (get the latest one):
          * Windows: `%LOCALAPPDATA%\Status\logs` 
          * Linux: `~/.config/Status/logs`
          * Mac: `~/Library/Application Support/Status/logs`

#### 8. Recovering Your Real Status Account

If you encounter an irrecoverable issue while testing with your real Status profile, you’ll need to manually recover your account:

* **Delete the app data folder** or **fully uninstall the app** (recommended if you're unsure how to delete the app data folder manually).
* **Reinstall** the app from the latest official release: \
 👉[ https://github.com/status-im/status-desktop/releases \
](https://github.com/status-im/status-desktop/releases)
* **Launch** the app, select **“Recover profile”**, and use the **recovery phrase** you backed up in Step 1.