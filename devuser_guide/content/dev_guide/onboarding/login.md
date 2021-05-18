---
title : "Login"
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

[User Docs for this section](/docs/onboarding/login/)

key source file: [`ui/onboarding/Login.qml`]()

## login process

key source file: [`ui/onboarding/Login.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/onboarding/Login.qml#L161)

key source file: [`src/app/login/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/login/view.nim#L102)

key source file: [`src/status/accounts.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/accounts.nim#L29)

key source file: [`src/status/libstatus/accounts.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/accounts.nim#L201)

The view will call `loginModel.login(password)`, the account to login is previously set by calling `loginModel.setCurrentAccount(index)`

## multiple accounts

key source file: [`ui/onboarding/Login.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/onboarding/Login.qml#L109)

key source file: [`ui/onboarding/Login/SelectAnotherAccountModal.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/onboarding/Login/SelectAnotherAccountModal.qml#L7)

key source file: [`ui/onboarding/Login/SelectAnotherAccountModal.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/onboarding/Login/SelectAnotherAccountModal.qml#L7)

key source file: [`src/app/login/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/login/view.nim#L19)

key source file: [`src/app/login/core.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/login/core.nim#L36)

key source file: [`src/status/accounts.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/accounts.nim#L26)

key source file: [`src/status/libstatus/accounts.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/accounts.nim#L77)

The account list is given by `loginModel` which is a QAbstractList, the accounts are filled in [login/core.nim](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/login/core.nim#L36)

## with only 1 account

key source file: [`ui/onboarding/Login.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/onboarding/Login.qml#L111)

key source file: [`ui/onboarding/Login/ConfirmAddExistingKeyModal.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/onboarding/Login/ConfirmAddExistingKeyModal.qml#L7)
