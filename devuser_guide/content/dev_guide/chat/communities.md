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

## Enabling communities

**Key source files**
- [`ui/app/AppLayouts/Profile/Sections/AdvancedContainer.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Profile/Sections/AdvancedContainer.qml#L101)
- [`ui/app/AppMain.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppMain.qml#L398)
- [`ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml#L55)

## General

### Joining a community

#### join community popup
- [`ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/ContactsColumn/AddChat.qml#L55)
- [`ui/app/AppLayouts/Chat/ContactsColumn.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/ContactsColumn.qml#L58)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml#L10)

#### listing communities
- [`ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml#L138)
- [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/app/chat/view.nim#L166)
- [`src/app/chat/views/community_list.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/app/chat/views/community_list.nim#L40)
- [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/app/chat/views/communities.nim#L109)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/status/chat.nim#L441)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/status/libstatus/chat.nim#L272)

#### selecting a community
- [`ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml#L212)
- [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/app/chat/view.nim#L166)
- [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/app/chat/views/communities.nim#L146)
- [`src/app/chat/views/community_item.nim`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/src/app/chat/views/community_item.nim#L40)

#### joining a community
- [`ui/app/AppLayouts/Chat/ContactsColumn.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/ContactsColumn.qml#L85)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CommunityDetailPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CommunityDetailPopup.qml#L243)
- [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/chat/views/communities.nim#L381)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/chat.nim#L524)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/libstatus/chat.nim#L434)

### Creating a community
- [`ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CommunitiesPopup.qml#L230)
- [`ui/app/AppLayouts/Chat/ContactsColumn.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/ContactsColumn.qml#L67)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateCommunityPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CreateCommunityPopup.qml#L438)
- [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/chat/views/communities.nim#L214)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/chat.nim#L472)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/libstatus/chat.nim#L292)

#### uploading a thumbnail image

// TODO: describe choosing file dialog, cropping image, uploading image

#### setting community color
- [`ColorDialog QML Type`](https://doc.qt.io/qt-5/qml-qtquick-dialogs-colordialog.html)
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateCommunityPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CreateCommunityPopup.qml#L323)

#### setting membership requirement
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateCommunityPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CreateCommunityPopup.qml#L350)
- [`ui/app/AppLayouts/Chat/CommunityComponents/MembershipRequirementPopup.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/MembershipRequirementPopup.qml#L9)

### Leaving a community
- [`ui/app/AppLayouts/Chat/CommunityComponents/CommunityList.qml`](https://github.com/status-im/status-desktop/blob/358091a8eb19f36c9843b42d61473e35ea87d05b/ui/app/AppLayouts/Chat/CommunityComponents/CommunityList.qml#L68)
- [`src/app/chat/views/communities.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/app/chat/views/communities.nim#L318)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/chat.nim#L503)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/af2ec66e0c7912baad871aea34efcc493e02de27/src/status/libstatus/chat.nim#L416)

## Manage Community

### Creating Channels
**Key source files**
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateChannelPopup.qml`](https://github.com/status-im/status-desktop/blob/4a407d920499e3c31244f019afc0ab20f2c8f5e3/ui/app/AppLayouts/Chat/CommunityComponents/CreateChannelPopup.qml)
- [`ui/app/AppLayouts/Chat/CommunityColumn.qml`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/ui/app/AppLayouts/Chat/CommunityColumn.qml#L84-L92)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/src/status/chat.nim#L478-L479)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/src/status/libstatus/chat.nim#L337-L364)
- [`src/app/chat/view.nim#L978-L990`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/src/app/chat/view.nim#L978-L990)

### Editing Channels
**Key source files**
- [`ui/app/AppLayouts/Chat/CommunityComponents/CreateChannelPopup.qml`](https://github.com/status-im/status-desktop/blob/4a407d920499e3c31244f019afc0ab20f2c8f5e3/ui/app/AppLayouts/Chat/CommunityComponents/CreateChannelPopup.qml#L179-L182)
- [`ui/app/AppLayouts/Chat/components/ChannelContextMenu.qml`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/ui/app/AppLayouts/Chat/components/ChannelContextMenu.qml#L109-L116)
- [`ui/app/AppMain.qml`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/ui/app/AppMain.qml#L283-L291)
- [`src/status/chat.nim`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/src/status/chat.nim#L481-L482)
- [`src/status/libstatus/chat.nim`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/src/status/libstatus/chat.nim#L366-L394)
- [`src/app/chat/view.nim`](https://github.com/status-im/status-desktop/blob/1f585d159b9814198863b729ed26a218c09ea56d/src/app/chat/view.nim#L992-L1002)

**Notes**
Editing a channel reuses the same modal popup used to create a channel, the difference being that it's prefilled with information from the selected channel, and has the `isEdit` attribute set to true, which determines the UI behavior for editing the channel as well as knowing the right slot to call.

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

## Context menu on the nav bar

## Initial Community
