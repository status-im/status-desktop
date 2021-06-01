---
title : "Group Chats"
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

### `confirmJoiningGroup`

%* [chatId])

### `leaveGroupChat`

%* [nil, chatId, true])

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
