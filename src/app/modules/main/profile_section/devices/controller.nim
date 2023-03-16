import Tables, chronicles
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/devices/service as devices_service

import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

const UNIQUE_SYNCING_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER* = "SyncingSection-AccountsModule-Authentication"

logScope:
  topics = "profile-section-devices-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    devicesService: devices_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  devicesService: devices_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.devicesService = devicesService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_DEVICES_LOADED) do(e: Args):
    let args = DevicesArg(e)
    self.delegate.onDevicesLoaded(args.devices)

  self.events.on(SIGNAL_ERROR_LOADING_DEVICES) do(e: Args):
    self.delegate.onDevicesLoadingErrored()

  self.events.on(SIGNAL_UPDATE_DEVICE) do(e: Args):
    let args = UpdateInstallationArgs(e)
    self.delegate.updateOrAddDevice(args.installation)
    
  self.events.on(SIGNAL_INSTALLATION_NAME_UPDATED) do(e: Args):
    let args = UpdateInstallationNameArgs(e)
    self.delegate.updateInstallationName(args.installationId, args.name)
    
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_SYNCING_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.pin, args.password, args.keyUid)

  self.events.on(SIGNAL_LOCAL_PAIRING_EVENT) do(e: Args):
    let args = LocalPairingEventArgs(e)
    self.delegate.onLocalPairingEvent(args.eventType, args.action, args.error)

  self.events.on(SIGNAL_LOCAL_PAIRING_STATUS_UPDATE) do(e: Args):
    let args = LocalPairingStatus(e)
    self.delegate.onLocalPairingStatusUpdate(args)


proc getMyInstallationId*(self: Controller): string =
  return self.settingsService.getInstallationId()

proc asyncLoadDevices*(self: Controller) =
  self.devicesService.asyncLoadDevices()

proc getAllDevices*(self: Controller): seq[InstallationDto] =
  return self.devicesService.getAllDevices()

proc setInstallationName*(self: Controller, installationId: string, name: string) =
  self.devicesService.setInstallationName(installationId, name)

proc syncAllDevices*(self: Controller) =
  self.devicesService.syncAllDevices()

proc advertise*(self: Controller) =
  self.devicesService.advertise()

proc enableDevice*(self: Controller, deviceId: string, enable: bool) =
  if enable:
    self.devicesService.enable(deviceId)
  else:
    self.devicesService.disable(deviceId)

#
# Pairing status
#

proc authenticateUser*(self: Controller, keyUid: string) =
  let data = SharedKeycarModuleAuthenticationArgs(
    uniqueIdentifier: UNIQUE_SYNCING_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

#
# Backend actions
#

proc validateConnectionString*(self: Controller, connectionString: string): string =
  return self.devicesService.validateConnectionString(connectionString)

proc getConnectionStringForBootstrappingAnotherDevice*(self: Controller, keyUid: string, password: string): string =
  return self.devicesService.getConnectionStringForBootstrappingAnotherDevice(keyUid, password)

proc inputConnectionStringForBootstrapping*(self: Controller, connectionString: string): string =
  return self.devicesService.inputConnectionStringForBootstrapping(connectionString)
