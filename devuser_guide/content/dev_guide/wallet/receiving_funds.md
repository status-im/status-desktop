---
title : "Receiving Funds"
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

## receiving funds on an account

### modal
- [`ui/app/AppLayouts/Wallet/WalletHeader.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/WalletHeader.qml#L136)
- [`ui/app/AppLayouts/Wallet/ReceiveModal.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/ReceiveModal.qml#L6)

### QR Code
- [`ui/app/AppLayouts/Wallet/ReceiveModal.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/ReceiveModal.qml#L53)
- [`src/app/profile/view.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/profile/view.nim#L130)
- [`src/app/profile/qrcode`](https://github.com/status-im/status-desktop/tree/master/src/app/profile/qrcode)

### listing accounts

- [`ui/app/AppLayouts/Wallet/ReceiveModal.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/app/AppLayouts/Wallet/ReceiveModal.qml#L43)
- [`ui/shared/AccountSelector.qml`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/ui/shared/AccountSelector.qml#L119)
- [`src/status/wallet.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/wallet.nim#L214)
- [`src/status/libstatus/wallet.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/libstatus/wallet.nim#L9)
- [`src/app/wallet/view.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/wallet/view.nim#L234)
- [`src/app/wallet/views/account_list.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/wallet/views/account_list.nim#L23)
- [`src/app/wallet/core.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/wallet/core.nim#L33)
