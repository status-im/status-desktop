---
title : "Chat List"
description: ""
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  dev:
    parent: "chat"
toc: true
---

## Join or start a public chat

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml#L52)

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn.qml#L32)

key source file: [`ui/app/AppLayouts/Chat/components/PublicChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/PublicChatPopup.qml#L31)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L588)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L131)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L21)

The public channel is joined by calling `chatsModel.joinChat(channelName.text, Constants.chatTypePublic)`
On the backend, the join action calls `status_chat.saveChat`, and adds a mailserver optic, it also emits a `channelJoined` event which will cause the UI to display that new channel

## Search for a Chat

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn.qml#L93)

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml#L41)

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/Channel.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/Channel.qml#L44)

The searchbox is aliased to as `searchStr`

```
property alias searchStr: searchBox.text
```

The ChannelList receives this as a paramter to the chat list and this is then passed to each member of the channel list

```
ChannelList {
    id: channelList
    searchStr: contactsColumn.searchStr.toLowerCase()
    channelModel: chatsModel.chats
}
```

The filtering works by checking the search string against the channel name and using this to set the item as visible or invisible

```
property bool isVisible: searchStr === "" || name.includes(searchStr)
```

## Suggested Channels

key source file: [`ui/app/AppLayouts/Chat/data/channelList.js`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/data/channelList.js#L1)

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/EmptyView.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/EmptyView.qml#L120)

key source file: [`ui/app/AppLayouts/Chat/components/SuggestedChannels.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/SuggestedChannels.qml#L9)

key source file: [`ui/app/AppLayouts/Chat/components/SuggestedChannel.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/SuggestedChannel.qml#L5)

## Badges

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/Channel.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/Channel.qml#L167)

### unread message counter

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml#`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml#L38)

key source file: [`src/status/chat/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat/chat.nim#L72)

This information comes from the property `unviewedMessagesCount` which is defined for each channel on the `channelListContent.channelModel`

### mentions @

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml#`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml#L39)

key source file: [`src/status/chat/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat/chat.nim#L76)

This information comes from the property `hasMentions` which is defined for each channel on the `channelListContent.channelModel`

## Context menu

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/Channel.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/Channel.qml#L188)

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/ChannelList.qml#L76)

key source file: [`ui/app/AppLayouts/Chat/components/ChannelContextMenu.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/ChannelContextMenu.qml#L8)
