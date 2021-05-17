---
title : "Pinned messages"
description: ""
lead: ""
date: 2021-05-17T08:48:23+00:00
lastmod: 2021-05-17T08:48:23+00:00
draft: false
images: []
menu:
  dev:
    parent: "chat"
toc: true
---

[User Docs for this section](/docs/chat/pinned_messages/)

[Original Pull Request](https://github.com/status-im/status-desktop/pull/2291)

## Adding a pin

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/status/libstatus/chat.nim#L407)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/app/chat/view.nim#L951)

### with the Pin button

Same button for the right click and the three dots menu

key source file: [`ui/app/AppLayouts/Chat/components/MessageContextMenu.qml`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/ui/app/AppLayouts/Chat/components/MessageContextMenu.qml#L150)

to open the menu with three dots: [`ui/app/AppLayouts/Chat/ChatColumn/MessageComponents/ChatButtons.qml`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/ui/app/AppLayouts/Chat/ChatColumn/MessageComponents/ChatButtons.qml#L109)

## Removing a pin

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/status/libstatus/chat.nim#L407)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/app/chat/view.nim#L956)


### with the Unpin button

Same button for the right click and the three dots menu

key source file: [`ui/app/AppLayouts/Chat/components/MessageContextMenu.qml`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/ui/app/AppLayouts/Chat/components/MessageContextMenu.qml#L150)

to open the menu with three dots: [`ui/app/AppLayouts/Chat/ChatColumn/MessageComponents/ChatButtons.qml`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/ui/app/AppLayouts/Chat/ChatColumn/MessageComponents/ChatButtons.qml#L109)


## Opening the pinned messages popup

key source file: [`ui/shared/status/StatusChatInfo.qml`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/ui/shared/status/StatusChatInfo.qml#L190)


## Loading pinned messages

key source file: [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/status/libstatus/chat.nim#L389)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/app/chat/view.nim#L667)

## Signal for new pins/unpins

key source file: [`src/status/signals/messages.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/status/signals/messages.nim#L69)

key source file: [`src/app/chat/event_handling.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/app/chat/event_handling.nim#L46)

key source file: [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/b4d87a8f90d56928f57fa81b663aa95b8ce311f4/src/app/chat/view.nim#L973)
