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

### `createCommunityChannel`
Creates a community channel with the given name and description, belonging to the community specified by the `communityId`.
Returns a `Chat` object containing the created community channel.
Throws an`RpcException` if there is an error returned from status-go.
*Parameters*
| Name          | Type     | Description  |
|---------------|----------|--------------|
| `communityId` | `string` | community id |
| `name` | `string` | community name |
| `description` | `string` | community description |

### `editCommunityChannel`
Edits a community channel, specified by `communityId` and `channelId`, with the given name and description.
Returns a `Chat` object with the edited community channel.
Throws an `RpcException` if there is an error returned from status-go.
*Parameters*
| Name          | Type     | Description  |
|---------------|----------|--------------|
| `communityId` | `string` | community id |
| `channelId` | `string` | channel id |
| `name` | `string` | community name |
| `description` | `string` | community description |

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
