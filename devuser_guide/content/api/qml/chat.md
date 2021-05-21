---
title : "Chat API"
description: ""
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  api:
    parent: "qml"
toc: true
---

The wallet model (exposed as `chatsModel`) is used for functions pertaining to chatting.

### Methods

Methods can be invoked by calling them directly on the `chatsModel`, ie `chatsModel.getOldestMessageTimestamp()`.

#### `getOldestMessageTimestamp()` : `QVariant<int64>`

Returns the last set UNIX timestamp of the oldest message. See `setLastMessageTimestamp` for logic on how this is determined.

**WIP**

*chatsModel.sendMessage(message: string)* - send a message to currently active channel

*chatsModel.joinChat(channel: string, chatTypeInt: int)* - join a channel

*chatsModel.groups.join()* - confirm joining group

*chatsModel.leaveActiveChat()* - leave currently active channel

*chatsModel.clearChatHistory()* - clear chat history of currently active channel

*chatsModel.groups.rename(newName: string)* - rename current active group

*chatsModel.blockContact(id: string)* - block contact

*chatsModel.addContact(id: string)*

*chatsModel.groups.create(groupName: string, pubKeys: string)*

### Signals
The `chatsModel` exposes the following signals, which can be consumed in QML using the `Connections` component (with a target of `chatsModel` and prefixed with `on`).
| Name          | Parameters     | Description  |
|---------------|----------|--------------|
| `oldestMessageTimestampChanged` | none | fired when the oldest message timestamp has changed |
**WIP**

### QtProperties
The following properties can be accessed directly on the `chatsModel`, ie `chatsModel.oldestMsgTimestamp`
| Name          | Type | Accessibility | Signal | Description  |
|---------------|------|---------------|--------|--------------|
| `oldestMsgTimestamp` | `QVariant<int64>` | `read` | `oldestMessageTimestampChanged` | Gets the last set UNIX timestamp of the oldest message. See `setLastMessageTimestamp` for logic on how this is determined. |
**WIP**

### WIP

#### ChannelsList
`QAbstractListModel` to expose chat channels.
The following roles are available to the model when bound to a QML control:

| Name          | Description  |
|---------------|--------------|
| `name` | name of the channel |
**WIP**

*chatsModel.chats* - get channel list (list)

channel object:
* name - 
* timestamp - 
* lastMessage.text - 
* unviewedMessagesCount - 
* identicon - 
* chatType - 
* color - 

*chatsModel.activeChannelIndex* - 
*chatsModel.activeChannel* - return currently active channel (object)

active channel object:
* id - 
* name - 
* color - 
* identicon - 
* chatType - (int)
* members - (list)
  * userName
  * pubKey
  * isAdmin
  * joined
  * identicon
* isMember(pubKey: string) - check if `pubkey` is a group member (bool)
* isAdmin(pubKey: string) - check if `pubkey` is a group admin (bool)

*chatsModel.messageList* - returns messages for the current channel (list)

message object:
* userName - 
* message - 
* timestamp - 
* clock - 
* identicon - 
* isCurrentUser - 
* contentType - 
* sticker - 
* fromAuthor - 
* chatId - 
* sectionIdentifier - 
* messageId - 
