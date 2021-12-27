{.used.}

import json

include ../../../common/[json_utils]

type Metadata* = object
  name*: string
  deviceType*: string
  fcmToken*: string

type DeviceDto* = object
  id*: string 
  identity*: string
  version*: int
  enabled*: bool
  timestamp*: int64
  metadata*: Metadata

proc isEmpty*(self: Metadata): bool =
  return self.name.len == 0

proc toMetadata(jsonObj: JsonNode): Metadata =
  result = Metadata()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("deviceType", result.deviceType)
  discard jsonObj.getProp("fcmToken", result.fcmToken)

proc toDeviceDto*(jsonObj: JsonNode): DeviceDto =
  result = DeviceDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("identity", result.identity)
  discard jsonObj.getProp("version", result.version)
  discard jsonObj.getProp("enabled", result.enabled)
  discard jsonObj.getProp("timestamp", result.timestamp)
  
  var metadataObj: JsonNode
  if(jsonObj.getProp("metadata", metadataObj)):
    result.metadata = toMetadata(metadataObj)