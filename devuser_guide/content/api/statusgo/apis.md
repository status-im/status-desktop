---
title : "APIs"
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

### `accounts_getAccounts`

")
### `eth_getTransactionReceipt`

%* [transactionHash])

### `eth_getBalance`

payload))

### `wallet_storePendingTransaction`

payload)

### `wallet_getPendingTransactions`

payload)

### `wallet_getPendingOutboundTransactionsByAddress`

payload)

### `wallet_deletePendingTransaction`

payload)

### `wallet_setInitialBlocksRange`

payload)

### `wallet_watchTransaction`

payload)

### `wallet_checkRecentHistory`

payload)

### `setInstallationMetadata`

%* [installationId, {"name": deviceName, "deviceType": deviceType}])

### `getOurInstallations`

%* []).parseJSON()["result"]

### `syncDevices`

%* [preferredName, photoPath])

### `sendPairInstallation`

".prefix)
### `enableInstallation`

%* [installationId])

### `disableInstallation`

%* [installationId])

### `wallet_getCustomTokens`

payload)

### `wallet_addCustomToken`

payload)

### `wallet_deleteCustomToken`

payload)

### `wallet_getTokensBalances`

payload).parseJson

### `eth_call`

payload)

### `settings_saveSetting`

%* [key, value])

### `web3_clientVersion`

"))["result"].getStr
### `settings_getSettings`

").parseJSON()["result"]
### `getLinkPreviewWhitelist`

%* []).parseJSON()["result"]

### `mailservers_addMailserver`

%* [

### `mailservers_getMailservers`

").parseJSON()["result"]
### `blockContact`

%* [

### `getContactByID`

%* [id])

### `contacts`

payload).parseJson

### `saveContact`

payload)

### `sendContactUpdate`

%* [publicKey, "", ""])

### `browsers_storeBookmark`

payload).parseJson["result"]

### `browsers_updateBookmark`

payload)

### `browsers_getBookmarks`

payload)

### `browsers_deleteBookmark`

payload)

### `loadFilters`

%* [filter(filters, proc(x:JsonNode):bool = x.kind != JNull)])

### `removeFilters`

%* [

### `saveChat`

%* [

### `createPublicChat`

%* [{"ID": chatId}])

### `createOneToOneChat`

%* [{"ID": chatId}])

### `deactivateChat`

%* [{ "ID": chat.id }])

### `createProfileChat`

%* [{ "ID": pubKey }])

### `chats`

".prefix))
### `chatMessages`

%* [chatId, cursorVal, limit])

### `emojiReactionsByChatID`

%* [chatId, cursorVal, limit])

### `sendEmojiReaction`

%* [chatId, messageId, emojiId]))["result"]

### `sendEmojiReactionRetraction`

%* [emojiReactionId]))["result"]

### `waku_generateSymKeyFromPassword`

%* [

### `sendChatMessage`

%* [

### `sendChatMessages`

%* [imagesJson])

### `markAllRead`

%* [chatId])

### `markMessagesSeen`

%* [chatId, messageIds])

### `confirmJoiningGroup`

%* [chatId])

### `leaveGroupChat`

%* [nil, chatId, true])

### `deleteMessagesByChatID`

%* [chatId])

### `changeGroupChatName`

%* [nil, chatId, newName])

### `createGroupChatWithMembers`

%* [nil, groupName, pubKeys])

### `addMembersToGroupChat`

%* [nil, chatId, pubKeys])

### `removeMemberFromGroupChat`

%* [nil, chatId, pubKey])

### `addAdminsToGroupChat`

%* [nil, chatId, [pubKey]])

### `updateMessageOutgoingStatus`

%* [messageId, status])

### `reSendChatMessage`

%*[messageId])

### `muteChat`

%*[chatId])

### `unmuteChat`

%*[chatId])

### `getLinkPreviewData`

%*[link])

### `communities`

".prefix).parseJSON()
### `joinedCommunities`

".prefix).parseJSON()
### `createCommunity`

%*[{

### `createCommunityChat`

%*[

### `createCommunityCategory`

%*[

### `editCommunityCategory`

%*[

### `reorderCommunityChat`

%*[

### `deleteCommunityCategory`

%*[

### `requestCommunityInfoFromMailserver`

%*[communityId])

### `joinCommunity`

%*[communityId])

### `leaveCommunity`

%*[communityId])

### `inviteUsersToCommunity`

%*[{

### `exportCommunity`

%*[communityId]).parseJson()["result"].getStr

### `importCommunity`

%*[communityKey])

### `removeUserFromCommunity`

%*[communityId, pubKey])

### `requestToJoinCommunity`

%*[{

### `acceptRequestToJoinCommunity`

%*[{

### `declineRequestToJoinCommunity`

%*[{

### `pendingRequestsToJoinForCommunity`

%*[communityId]).parseJSON()

### `myPendingRequestsToJoin`

".prefix).parseJSON()
### `banUserFromCommunity`

%*[{

### `chatPinnedMessages`

%* [chatId, cursorVal, limit])

### `sendPinMessage`

%*[{

### `startMessenger`

".prefix)
### `admin_addPeer`

%* [peer])

### `admin_removePeer`

%* [peer])

### `markTrustedPeer`

%* [peer])

### `eth_getBlockByNumber`

%* [blockNumber, false])

### `wallet_getTransfersByAddress`

%* [address, newJNull(), limit, fetchMore])

### `eth_accounts`

")
### `accounts_saveAccounts`

%* [

### `accounts_deleteAccount`

%* [address])

### `multiaccounts_storeIdentityImage`

%* [keyUID, imagePath, aX, aY, bX, bY]).parseJson

### `multiaccounts_getIdentityImages`

%* [keyUID]).parseJson

### `multiaccounts_deleteIdentityImage`

%* [keyUID]).parseJson

### `eth_estimateGas`

%*[%tx])

### `mailservers_ping`

%* [

### `updateMailservers`

%* [[peer]])

### `mailservers_deleteMailserver`

%* [peer])

### `requestAllHistoricMessages`

%*[])

### `syncChatFromSyncedFrom`

%*[chatId])

### `fillGaps`

%*[chatId, messageIds])


## Library Calls

### `validateMnemonic(mnemonic)`

### `callRPC(inputJSON)`

### `callPrivateRPC(inputJSON)`

### `sendTransaction(inputJSON, hashed_password)`

### `signMessage(rpcParams)`

### `signTypedData(data, address, password)`

### `multiAccountGenerateAndDeriveAddresses($multiAccountConfig)`

### `generateAlias(publicKey)`

### `identicon(publicKey)`

### `initKeystore(KEYSTOREDIR)`

### `openAccounts(STATUSGODIR).parseJson`

### `saveAccountAndLogin(accountData, hashedPassword, settingsJSON, configJSON, $subaccountData)`

### `multiAccountStoreDerivedAccounts($multiAccount);`

### `addPeer(peer)`

### `login($toJson(account), hashedPassword)`

### `multiAccountLoadAccount($inputJson)`

### `verifyAccountPassword(KEYSTOREDIR, address, hashedPassword)`

### `multiAccountImportMnemonic($mnemonicJson)`

### `multiAccountImportPrivateKey($privateKeyJson)`

### `multiAccountStoreAccount($(%*{"accountID": account.id, "password": hashedPassword})));`

### `multiAccountDeriveAddresses($deriveJson))`

### `logout(), StatusGoError)`

