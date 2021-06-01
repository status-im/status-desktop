---
title : "Wallet & Transactions"
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

### `wallet_storePendingTransaction`

### `wallet_getPendingTransactions`

### `wallet_getPendingOutboundTransactionsByAddress`

### `wallet_deletePendingTransaction`

### `wallet_setInitialBlocksRange`

### `wallet_watchTransaction`

### `wallet_checkRecentHistory`

### `wallet_getCustomTokens`

### `wallet_addCustomToken`

### `wallet_deleteCustomToken`

### `wallet_getTokensBalances`

## Library Calls

### `acceptRequestAddressForTransaction`

%* [messageId, address])

### `declineRequestAddressForTransaction`

%* [messageId])

### `declineRequestTransaction`

%* [messageId])

### `requestAddressForTransaction`

%* [chatId, fromAddress, amount, tokenAddress])

### `requestTransaction`

%* [chatId, amount, tokenAddress, fromAddress])

### `sendTransaction(inputJSON, hashed_password)`

### `wallet_getTransfersByAddress`

%* [address, newJNull(), limit, fetchMore])
