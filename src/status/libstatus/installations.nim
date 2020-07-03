import json, core, utils, system

proc setInstallationMetadata*(installationId: string, deviceName: string, deviceType: string): string =
  result = callPrivateRPC("setInstallationMetadata".prefix, %* [installationId, {"name": deviceName, "deviceType": deviceType}])
  # TODO: handle errors

proc getOurInstallations*(): string =
  result = callPrivateRPC("getOurInstallations".prefix, %* [])
  echo result
