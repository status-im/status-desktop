---
title : "Creating an account"
description: ""
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  dev:
    parent: "onboarding"
toc: true
---

[User Docs for this section](/docs/onboarding/account_creation/)

## create account

key source file: [`ui/onboarding/GenKey.qml`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/ui/onboarding/GenKey.qml#L12)

### listing accounts

key source file: [`ui/onboarding/GenKeyModal.qml`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/ui/onboarding/GenKeyModal.qml#L9)

#### account list

key source file: [`src/app/onboarding/core.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/app/onboarding/core.nim#L36)

key source file: [`src/status/accounts.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/status/accounts.nim#L18)

key source file: [`src/status/libstatus/accounts.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/status/libstatus/accounts.nim#L46)

The list of accounts is a QAbstrastListModel defined as `onboardingModel` (`/src/app/onboarding/view.nim`) and populated in `/src/app/onboarding/core.nim`

#### choosing an account

key source file: [`src/app/onboarding/view.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/app/onboarding/view.nim#L80)

key source file: [`src/app/onboarding/views/account_info.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/app/onboarding/views/account_info.nim#L22)

key source file: [`src/status/libstatus/types.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/status/libstatus/types.nim#L65)

`onNextClick(selectedIndex)` is defined at `GenKey.qml` and called in `GenKeyModal.qml` when an account is selected

```
onboardingModel.setCurrentAccount(selectedIndex) // set this account in the model
createPasswordModal.open() // opens the next modal
```

### create password

key source file: [`ui/onboarding/GenKey.qml`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/ui/onboarding/GenKey.qml#L27)

key source file: [`ui/onboarding/CreatePasswordModal.qml`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/ui/onboarding/CreatePasswordModal.qml#L150)

key source file: [`src/app/onboarding/view.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/app/onboarding/view.nim#L98)

key source file: [`src/status/accounts.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/status/accounts.nim#L37)

key source file: [`src/status/libstatus/accounts.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/status/libstatus/accounts.nim#L183)

Calling `onboardingModel.storeDerivedAndLogin(password)` will store that account and login, this will use the account set in the previous step

## access existing key

key source file: [`ui/onboarding/EnterSeedPhraseModal.qml`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/ui/onboarding/EnterSeedPhraseModal.qml#L8)

key source file: [`ui/onboarding/ExistingKey.qml`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/ui/onboarding/ExistingKey.qml#L14)

key source file: [`ui/onboarding/CreatePasswordModal.qml`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/ui/onboarding/CreatePasswordModal.qml#L150)

key source file: [`src/app/onboarding/view.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/app/onboarding/view.nim#L87)

key source file: [`src/status/accounts.nim`](https://github.com/status-im/status-desktop/blob/c910613131d5813fb3fc4962d4f1a621d5fac033/src/status/accounts.nim#L40)
