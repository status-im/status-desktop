---
title : "Communities"
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

## General
### Joining a community
### Creating a community
### Leaving a community
## Manage Community
### Creating Channels
#### Public Channels
#### Private Channels
### Categories

key source file: [`ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml)

key source file: [`ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml`](https://github.com/status-im/status-desktop/blob/e5b42b3fb568b955fb05fbf34673aec0eb5adda8/ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml)

key source file: [`src/app/chat/views/category_list.nim`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/src/app/chat/views/category_list.nim)

key source file: [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/src/app/chat/views/communities.nim)

key source file: [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/src/app/chat/views/communities.nim)

status-go: [Community categories #2228](https://github.com/status-im/status-go/pull/2228)

Channels within a community might be organized in categories. Only the community admin might create/edit/delete a category. An admin can create/edit a category and add channels to it as long as those categories have not been assigned before (`categoryId == ""`). Deleting a category will remove the `categoryId` from any chat assigned to the category being deleted. Creating a channel in a category works by calling `wakuext_reorderCommunityChat` after the chat is created, then the `Chat` is immediatly assigned a `categoryId`.

### Transfer ownership
### Share Community
### See Members
### Kick Member
### Invite People
### Back up Community
