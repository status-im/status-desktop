---
title : "1 on 1 Chats"
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

[User Docs for this section](/docs/chat/one_on_one/)

## sending images

### with upload button

### with drag & drop

## transactions

### send transaction

### request payment

## start new 1 on 1 Chat

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml#L36)

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn.qml#L50)

key source file: [`ui/app/AppLayouts/Chat/components/PrivateChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/PrivateChatPopup.qml#L9)

key source file: [`ui/shared/ContactsListAndSearch.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/ContactsListAndSearch.qml#L7)

### with existing contact

key source file: [`ui/shared/ContactsListAndSearch.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/ContactsListAndSearch.qml#L141)

key source file: [`ui/shared/ExistingContacts.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/ExistingContacts.qml#L37)

key source file: [`src/app/profile/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/profile/view.nim#L26)

key source file: [`src/app/profile/views/contact_list.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/profile/views/contact_list.nim#L21)

key source file: [`src/app/profile/core.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/profile/core.nim#L67)

key source file: [`src/app/profile/core.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/profile/core.nim#L67)

key source file: [`src/status/contacts.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/contacts.nim#L52)

key source file: [`src/status/libstatus/contacts.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/contacts.nim#L26)

### by ENS username

key source file: [`ui/shared/ContactsListAndSearch.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/ContactsListAndSearch.qml#L51)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L801)

key source file: [`ui/app/AppLayouts/Chat/components/PrivateChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/PrivateChatPopup.qml#L37)

The ENS search uses a debouce of 500ms to avoid unnecessary searches, and calls [`chatsModel.resolveENS(ensName)`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/ContactsListAndSearch.qml#L29)

// TODO: describe how thread pool works

### by chat key

key source file: [`ui/app/AppLayouts/Chat/components/PrivateChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/PrivateChatPopup.qml#L37)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L588)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L131)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L21)

The chat is initialized with `chatsModel.joinChat(pubKey, Constants.chatTypeOneToOne)`, on the backend this calls the `saveChat` RPC method
