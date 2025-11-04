import chronicles
import io_interface

import ../../../../core/eventemitter
import app_service/service/general/service as general_service
import app_service/service/devices/service as devices_service
import app_service/service/settings/service as settings_service
import app_service/service/node_configuration/service as node_configuration_service
import app_service/common/types

logScope:
  topics = "profile-section-sync-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    nodeConfigurationService: node_configuration_service.Service
    generalService: general_service.Service
    devicesService: devices_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    generalService: general_service.Service,
    devicesService: devices_service.Service,
  ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.nodeConfigurationService = nodeConfigurationService
  result.generalService = generalService
  result.devicesService = devicesService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_LOCAL_BACKUP_IMPORT_COMPLETED) do(e: Args):
    let args = LocalBackupImportArg(e)
    self.delegate.onLocalBackupImportCompleted(args.error)

proc getUseMailservers*(self: Controller): bool =
  return self.settingsService.getUseMailservers()

proc setUseMailservers*(self: Controller, value: bool): bool =
  return self.settingsService.toggleUseMailservers(value)

proc performLocalBackup*(self: Controller): string =
  return self.devicesService.performLocalBackup()

proc importLocalBackupFile*(self: Controller, filePath: string) =
  self.generalService.asyncImportLocalBackupFile(filePath)
