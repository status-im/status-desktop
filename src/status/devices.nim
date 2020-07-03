import system
import libstatus/settings
import libstatus/installations
import json

proc setDeviceName*(name: string) =
  discard getSettings()
  discard setInstallationMetadata(getSetting[string]("installation-id", "", true), name, hostOs)

proc isDeviceSetup*():bool =
  discard getSettings()
  let installationId = getSetting[string]("installation-id", "", true)
  let responseResult = parseJSON($getOurInstallations())["result"]
  if responseResult.kind == JNull:
    return false
  for installation in responseResult:
    if installation["id"].getStr == installationId:
      return installation["metadata"].kind != JNull
  result = false

proc syncAllDevices*() =
  discard syncDevices()

proc advertise*() =
  discard sendPairInstallation()
