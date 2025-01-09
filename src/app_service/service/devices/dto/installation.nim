{.used.}

import json

include ../../../common/[json_utils]

# NOTE: DeviceType equeals to:
#       - on Desktop (`hostOS` from system.nim):
#           "windows", "macosx", "linux", "netbsd", "freebsd",
#           "openbsd", "solaris", "aix", "haiku", "standalone".
#       - on Mobile (from platform.cljs):
#           "android", "ios"

type InstallationMetadata* = object
  name*: string
  deviceType*: string
  fcmToken*: string

type InstallationDto* = ref object
  id*: string
  identity*: string
  version*: int
  enabled*: bool
  timestamp*: int64
  metadata*: InstallationMetadata

proc isEmpty*(self: InstallationMetadata): bool =
  return self.name.len == 0

proc toMetadata(jsonObj: JsonNode): InstallationMetadata =
  result = InstallationMetadata()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("deviceType", result.deviceType)
  discard jsonObj.getProp("fcmToken", result.fcmToken)

proc toInstallationDto*(jsonObj: JsonNode): InstallationDto =
  result = InstallationDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("identity", result.identity)
  discard jsonObj.getProp("version", result.version)
  discard jsonObj.getProp("enabled", result.enabled)
  discard jsonObj.getProp("timestamp", result.timestamp)

  var metadataObj: JsonNode
  if (jsonObj.getProp("metadata", metadataObj)):
    result.metadata = toMetadata(metadataObj)
