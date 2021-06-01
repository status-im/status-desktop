---
title : "General"
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

### `setInstallationMetadata`

%* [installationId, {"name": deviceName, "deviceType": deviceType}])

### `getOurInstallations`

%* []).parseJSON()["result"]

### `syncDevices`

%* [preferredName, photoPath])

### `sendPairInstallation`

".prefix)
### `enableInstallation`

%* [installationId])

### `disableInstallation`

%* [installationId])

### `settings_getSettings`

### `settings_saveSetting`

%* [key, value])

### `web3_clientVersion`

### `startMessenger`

### `admin_addPeer`

%* [peer])

### `admin_removePeer`

%* [peer])

### `markTrustedPeer`

%* [peer])

## Library Calls

### `callRPC(inputJSON)`

### `callPrivateRPC(inputJSON)`

### `signMessage(rpcParams)`

### `signTypedData(data, address, password)`

### `initKeystore(KEYSTOREDIR)`

### `addPeer(peer)`

### `login($toJson(account), hashedPassword)`

### `logout(), StatusGoError)`
