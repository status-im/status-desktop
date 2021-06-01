---
title : "Adding Accounts"
description: ""
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  dev:
    parent: "wallet"
toc: true
---

// TODO: needs more detail, specially about the backend

## Adding an Account
- [`ui/app/AppLayouts/Wallet/LeftTab.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/LeftTab.qml#L66)
- [`ui/app/AppLayouts/Wallet/components/AddAccount.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/components/AddAccount.qml#L7)

### Generating an account
- [`ui/app/AppLayouts/Wallet/components/GenerateAccountModal.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/components/GenerateAccountModal.qml#L103)
- [`src/app/wallet/view.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/wallet/view.nim#L416)
- [`src/status/wallet.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/wallet.nim#L251)

### Adding a watch only address
- [`ui/app/AppLayouts/Wallet/components/AddWatchOnlyAccount.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/components/AddWatchOnlyAccount.qml#L103)
- [`src/app/wallet/view.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/wallet/view.nim#L434)
- [`src/status/wallet.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/wallet.nim#L295)

### Adding an account using a seed phrase
- [`ui/app/AppLayouts/Wallet/components/AddAccountWithSeed.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/components/AddAccountWithSeed.qml#L131)
- [`src/app/wallet/view.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/wallet/view.nim#L422)
- [`src/status/wallet.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/wallet.nim#L271)

### Adding an account using a private key
- [`ui/app/AppLayouts/Wallet/components/AddAccountWithPrivateKey.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/components/AddAccountWithPrivateKey.qml#L129)
- [`src/app/wallet/view.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/wallet/view.nim#L428)
- [`src/status/wallet.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/wallet.nim#L284)
