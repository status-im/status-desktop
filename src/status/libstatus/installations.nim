import json, core, utils, system

var installations: JsonNode = %*{}
var dirty: bool = true

proc setInstallationMetadata*(installationId: string, deviceName: string, deviceType: string): string =
  result = callPrivateRPC("setInstallationMetadata".prefix, %* [installationId, {"name": deviceName, "deviceType": deviceType}])
  # TODO: handle errors

proc getOurInstallations*(useCached: bool = true): JsonNode =
  if useCached and not dirty:
    return installations
  installations = callPrivateRPC("getOurInstallations".prefix, %* []).parseJSON()["result"]
  dirty = false
  result = installations

proc syncDevices*(preferredName: string): string =
  # TODO change this to identicon when status-go is updated
  let photoPath = ""
  result = callPrivateRPC("syncDevices".prefix, %* [preferredName, photoPath])

proc sendPairInstallation*(): string =
  result = callPrivateRPC("sendPairInstallation".prefix)

proc enableInstallation*(installationId: string): string =
  result = callPrivateRPC("enableInstallation".prefix, %* [installationId])

proc disableInstallation*(installationId: string): string =
  result = callPrivateRPC("disableInstallation".prefix, %* [installationId])
