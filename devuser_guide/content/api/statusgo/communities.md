---
title : "Communities"
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

### `communities`

### `joinedCommunities`

### `createCommunity`

### `createCommunityChat`

### `createCommunityCategory`

### `editCommunityCategory`

### `reorderCommunityChat`

### `deleteCommunityCategory`

### `requestCommunityInfoFromMailserver`

%*[communityId])

### `joinCommunity`

%*[communityId])

### `leaveCommunity`

%*[communityId])

### `inviteUsersToCommunity`

### `exportCommunity`

%*[communityId]).parseJson()["result"].getStr

### `importCommunity`

%*[communityKey])

### `removeUserFromCommunity`

%*[communityId, pubKey])

### `requestToJoinCommunity`

### `acceptRequestToJoinCommunity`

### `declineRequestToJoinCommunity`

### `pendingRequestsToJoinForCommunity`

%*[communityId]).parseJSON()

### `myPendingRequestsToJoin`

### `banUserFromCommunity`

### `chatPinnedMessages`

%* [chatId, cursorVal, limit])

### `sendPinMessage`
