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
Channels within a community might be organized in categories. Only the community admin might create/edit/delete a category. Creating a channel in a category works by calling `wakuext_reorderCommunityChat` after the chat is created, then the `Chat` is immediatly assigned a `categoryId`.
#### Creating Categories

**Key source files**
- [`src/app/chat/views/category_list.nim`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/src/app/chat/views/category_list.nim#L58-L62)
- [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/src/app/chat/views/communities.nim#L247-L256)
- [`src/app/chat/views/community_item`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/app/chat/views/community_item.nim#L156-L159)
- [`src/app/chat/views/community_list.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/app/chat/views/community_list.nim#L132-L134)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/status/chat.nim#L472-L473)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/status/libstatus/chat.nim#L317-L331)
- [`src/status/signals/messages.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/status/signals/messages.nim#L200-L215)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml`](https://github.com/status-im/status-desktop/blob/e5b42b3fb568b955fb05fbf34673aec0eb5adda8/ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml)
- [`ui/app/AppLayouts/Chat/CommunityColumn.qml`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/ui/app/AppLayouts/Chat/CommunityColumn.qml)

**PR**
- status-desktop: [feat: create community categories #2564](https://github.com/status-im/status-desktop/pull/2564)
- status-go: [Community categories #2228](https://github.com/status-im/status-go/pull/2228)

**Notes**
An admin can create a category and add channels to it as long as those categories have not been assigned before (`categoryId == ""`). 

#### Editing Categories

**Key source files**
- [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/aea1321b0e9684e67ed4552182544e80c5e70709/src/app/chat/views/communities.nim#L259-L266)
- [`src/app/chat/views/community_item.nim`](https://github.com/status-im/status-desktop/blob/aea1321b0e9684e67ed4552182544e80c5e70709/src/app/chat/views/community_item.nim#L182-L187)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/aea1321b0e9684e67ed4552182544e80c5e70709/src/status/chat.nim#L475-L476)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/aea1321b0e9684e67ed4552182544e80c5e70709/src/status/libstatus/chat.nim#L334-L343)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml`](https://github.com/status-im/status-desktop/blob/e5b42b3fb568b955fb05fbf34673aec0eb5adda8/ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml)

**PR**
- status-desktop: [feat: edit community categories #2569](https://github.com/status-im/status-desktop/pull/2569)
- status-go: [Community categories #2228](https://github.com/status-im/status-go/pull/2228)

**Notes**
Editing categories reuses the same modal popup used to create categories, the difference being that it's prefilled with information from the selected category, and has the `isEdit` attribute set to true, which determines the UI behavior for editing the category as well as knowing the right slot to call.

#### Delete Categories

**Key source files**
- [`src/app/chat/views/community_item.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/app/chat/views/community_item.nim#L161-L166)
- [`src/app/chat/views/community_list.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/app/chat/views/community_list.nim#L148-L154)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/status/chat.nim#L475-L476)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/489e5f42b6de5dca706eb690bd65d5c19ee1dfd8/src/status/libstatus/chat.nim#L344-L351)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml`](https://github.com/status-im/status-desktop/blob/3f56db35bac7cc3b0f3769ef1afbd5060b10d03f/ui/app/AppLayouts/Chat/CommunityComponents/CategoryList.qml)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml`](https://github.com/status-im/status-desktop/blob/e5b42b3fb568b955fb05fbf34673aec0eb5adda8/ui/app/AppLayouts/Chat/CommunityComponents/CreateCategoryPopup.qml)

**PR**
- status-desktop: [feat: edit community categories #2569](https://github.com/status-im/status-desktop/pull/2569)
- status-go: [Community categories #2228](https://github.com/status-im/status-go/pull/2228)

**Notes**
Deleting a category will remove the `categoryId` from any chat assigned to the category being deleted. 


### Transfer ownership
### Share Community
### See Members
### Kick Member
### Invite People
### Back up Community
