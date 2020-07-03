import json, core, utils, system

proc setInstallationMetadata*(installationId: string, deviceName: string, deviceType: string): string =
  result = callPrivateRPC("setInstallationMetadata".prefix, %* [installationId, {"name": deviceName, "deviceType": deviceType}])
  # TODO: handle errors

proc getOurInstallations*(): string =
  result = callPrivateRPC("getOurInstallations".prefix, %* [])

proc syncDevices*(): string =
  # These are not being used at the moment
  let preferredName = ""
  let photoPath = ""
  result = callPrivateRPC("syncDevices".prefix, %* [preferredName, photoPath])

proc sendPairInstallation*(): string =
  result = callPrivateRPC("sendPairInstallation".prefix)

