import system
import libstatus/settings
import libstatus/types
import libstatus/installations
import profile/devices
import json

proc setDeviceName*(name: string) =
  discard setInstallationMetadata(getSetting[string](Setting.InstallationId, "", true), name, hostOs)

proc isDeviceSetup*():bool =
  let installationId = getSetting[string](Setting.InstallationId, "", true)
  let responseResult = getOurInstallations()
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

proc getAllDevices*():seq[Installation] =
  let responseResult = getOurInstallations()
  let installationId = getSetting[string](Setting.InstallationId, "", true)
  result = @[]
  if responseResult.kind != JNull:
    for inst in responseResult:
      var device = inst.toInstallation
      if device.installationId == installationId:
        device.isUserDevice = true
      result.add(device)

proc enable*(installationId: string) =
  # TODO handle errors
  discard enableInstallation(installationId)

proc disable*(installationId: string) =
  discard disableInstallation(installationId)
