---
title : "Group Chats"
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

## Starting a group chat

### Opening new group chat modal

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml#L44)

key source file: [`ui/app/AppLayouts/Chat/ContactsColumn.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ContactsColumn.qml#L41)

key source file: [`ui/app/AppLayouts/Chat/components/GroupChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupChatPopup.qml#L10)

### Choosing Members

key source file: [`ui/app/AppLayouts/Chat/components/GroupChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupChatPopup.qml#L126)

key source file: [`ui/app/AppLayouts/Chat/components/ContactList.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/ContactList.qml#L6)

// TODO: unclear where the member list is coming from
// TODO: unclear how it switches to the next screen

### Setting Group Name 

key source file: [`ui/app/AppLayouts/Chat/components/GroupChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupChatPopup.qml#L107)

### Creating the group chat

key source file: [`ui/app/AppLayouts/Chat/components/GroupChatPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupChatPopup.qml#L67)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L153)

key source file: [`src/app/chat/views/groups.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/views/groups.nim#L36)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L403)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L217)

## Context menu

key source file: [`ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml#L67)

### Group Information

key source file: [`ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml#L107)

see [Group Information](#group-information-1)

### Clear History

key source file: [`ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml#L115)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L749)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L263)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L211)

### Leave group

key source file: [`ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ChatColumn/TopBar.qml#L123)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L719)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L248)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L208)

// TODO: unclear worker code https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L719
// TODO: unclear reason deactivateChat https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L248

## Group Information

key source file: [`ui/app/AppLayouts/Chat/ChatLayout.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/ChatLayout.qml#L48)

key source file: [`ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml#L9)

## Adding Members

key source file: [`ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml#L49)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L153)

key source file: [`src/app/chat/views/groups.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/views/groups.nim#L40)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L411)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L220)

## Removing Members

key source file: [`ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml#L299)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L153)

key source file: [`src/app/chat/views/groups.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/views/groups.nim#L44)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L415)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L223)

## Make other members admin

key source file: [`ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml#L290)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/view.nim#L153)

key source file: [`src/app/chat/views/groups.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/views/groups.nim#L47)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L419)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L226)

## Renaming Group

key source file: [`ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/GroupInfoPopup.qml#L134)

key source file: [`ui/app/AppLayouts/Chat/components/RenameGroupPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/app/AppLayouts/Chat/components/RenameGroupPopup.qml#L11)

key source file: [`src/app/chat/views/groups.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/app/chat/views/groups.nim#L33)

key source file: [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/chat.nim#L393)

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/src/status/libstatus/chat.nim#L214)
