---
title : "Chat"
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

### `mailservers_addMailserver`

### `mailservers_getMailservers`

### `loadFilters`

%* [filter(filters, proc(x:JsonNode):bool = x.kind != JNull)])

### `removeFilters`

### `saveChat`

### `createPublicChat`

%* [{"ID": chatId}])

### `createOneToOneChat`

%* [{"ID": chatId}])

### `deactivateChat`

%* [{ "ID": chat.id }])

### `createProfileChat`

%* [{ "ID": pubKey }])

### `chats`

### `chatMessages`

%* [chatId, cursorVal, limit])

### `emojiReactionsByChatID`

%* [chatId, cursorVal, limit])

### `sendEmojiReaction`

%* [chatId, messageId, emojiId]))["result"]

### `sendEmojiReactionRetraction`

%* [emojiReactionId]))["result"]

### `waku_generateSymKeyFromPassword`

### `sendChatMessage`

### `sendChatMessages`

%* [imagesJson])

### `markAllRead`

%* [chatId])

### `markMessagesSeen`

%* [chatId, messageIds])

### `deleteMessagesByChatID`

%* [chatId])

### `updateMessageOutgoingStatus`

%* [messageId, status])

### `reSendChatMessage`

%*[messageId])

### `muteChat`

%*[chatId])

### `unmuteChat`

%*[chatId])

### `getLinkPreviewData`

### `getLinkPreviewWhitelist`
%*[link])

### `mailservers_ping`

### `updateMailservers`

%* [[peer]])

### `mailservers_deleteMailserver`

%* [peer])

### `requestAllHistoricMessages`

### `syncChatFromSyncedFrom`

%*[chatId])

### `fillGaps`

%*[chatId, messageIds])
