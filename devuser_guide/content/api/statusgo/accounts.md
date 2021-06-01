---
title : "Accounts"
description: ""
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  api:
    parent: "statusgo"
toc: true
---

## RPC Calls

### `accounts_getAccounts`

### `accounts_saveAccounts`

### `accounts_deleteAccount`

%* [address])

### `multiaccounts_storeIdentityImage`

%* [keyUID, imagePath, aX, aY, bX, bY]).parseJson

### `multiaccounts_getIdentityImages`

%* [keyUID]).parseJson

### `multiaccounts_deleteIdentityImage`

%* [keyUID]).parseJson

## Library Calls

### `multiAccountGenerateAndDeriveAddresses($multiAccountConfig)`

### `generateAlias(publicKey)`

### `identicon(publicKey)`

### `openAccounts(STATUSGODIR).parseJson`

### `saveAccountAndLogin(accountData, hashedPassword, settingsJSON, configJSON, $subaccountData)`

### `multiAccountStoreDerivedAccounts($multiAccount);`

### `multiAccountLoadAccount($inputJson)`

### `verifyAccountPassword(KEYSTOREDIR, address, hashedPassword)`

### `multiAccountImportMnemonic($mnemonicJson)`

### `multiAccountImportPrivateKey($privateKeyJson)`

### `multiAccountStoreAccount($(%*{"accountID": account.id, "password": hashedPassword})));`

### `multiAccountDeriveAddresses($deriveJson))`

### `validateMnemonic(mnemonic)`
