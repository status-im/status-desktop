import json, json_serialization, sequtils, chronicles, system

import status/statusgo_backend/settings as status_go_settings
import status/statusgo_backend/installations as status_go_installations
import status/devices as status_devices
import status/types/[installation]
from status/types/setting import Setting

import ./service_interface

export service_interface

logScope:
  topics = "settings-service"

const DESKTOP_VERSION {.strdefine.} = "0.0.0"

type 
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard

method setDeviceName*(self: Service, deviceName: string) =
  let installation_setting = status_go_settings.getSetting[string](Setting.InstallationId, "", true)
  discard status_go_installations.setInstallationMetadata(installation_setting, deviceName, hostOs)

method syncAllDevices*(self: Service) =
  let preferredUsername = status_go_settings.getSetting[string](Setting.PreferredUsername, "")
  discard status_go_installations.syncDevices(preferredUsername)

method advertiseDevice*(self: Service) =
  discard status_go_installations.sendPairInstallation()

method getAllDevices*(self: Service): seq[Installation] =
  status_devices.getAllDevices()

method isDeviceSetup*(self: Service): bool =
  status_devices.isDeviceSetup()

method enableInstallation*(self: Service, installationId: string, enable: bool) =
  if enable:
    discard status_go_installations.enableInstallation(installationId)
  else:
    discard status_go_installations.disableInstallation(installationId)
