import chronicles
import io_interface

import ../../../../global/app_signals
import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/stickers/service as stickers_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service

logScope:
  topics = "profile-section-advanced-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    stickersService: stickers_service.Service
    nodeConfigurationService: node_configuration_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service,
  stickersService: stickers_service.Service,
  nodeConfigurationService: node_configuration_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.nodeConfigurationService = nodeConfigurationService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getFleet*(self: Controller): string =
  self.nodeConfigurationService.getFleetAsString()

proc changeFleetTo*(self: Controller, fleet: string) =
  if (not self.nodeConfigurationService.setFleet(fleet)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set fleet"
    return

  self.delegate.onFleetSet()

proc getBloomLevel*(self: Controller): string =
  return self.nodeConfigurationService.getBloomLevel()

proc setBloomLevel*(self: Controller, bloomLevel: string) =
  if (not self.nodeConfigurationService.setBloomLevel(bloomLevel)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set bloom level"
    return

  self.delegate.onBloomLevelSet()

proc getLogMaxBackups*(self: Controller): int =
  return self.nodeConfigurationService.getLogMaxBackups()

proc setMaxLogBackups*(self: Controller, value: int) =
  if(not self.nodeConfigurationService.setMaxLogBackups(value)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set the Max Log Backups"
    return

  self.delegate.onLogMaxBackupsChanged()

proc getWakuV2LightClientEnabled*(self: Controller): bool =
  return self.nodeConfigurationService.getV2LightMode()

proc setWakuV2LightClientEnabled*(self: Controller, enabled: bool) =
  if (not self.nodeConfigurationService.setV2LightMode(enabled)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set WakuV2 light client"
    return

  self.delegate.onWakuV2LightClientSet()

proc enableDeveloperFeatures*(self: Controller) =
  discard self.settingsService.saveTelemetryServerUrl(DEFAULT_TELEMETRY_SERVER_URL)
  discard self.settingsService.saveAutoMessageEnabled(true)
  discard self.nodeConfigurationService.setLogLevel(LogLevel.DEBUG)

  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

proc isTelemetryEnabled*(self: Controller): bool =
  return self.settingsService.getTelemetryServerUrl().len > 0

proc toggleTelemetry*(self: Controller) =
  var value = ""
  if(not self.isTelemetryEnabled()):
    value = DEFAULT_TELEMETRY_SERVER_URL

  if(not self.settingsService.saveTelemetryServerUrl(value)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't toggle telemetry message"
    return

  self.delegate.onTelemetryToggled()

proc toggleAutoMessage*(self: Controller) =
  let enabled = self.settingsService.autoMessageEnabled()
  if(not self.settingsService.saveAutoMessageEnabled(not enabled)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't toggle auto message"
    return

  self.delegate.onAutoMessageToggled()

proc isAutoMessageEnabled*(self: Controller): bool =
  return self.settingsService.autoMessageEnabled()

proc isDebugEnabled*(self: Controller): bool =
  return self.nodeConfigurationService.isDebugEnabled()
  
proc toggleDebug*(self: Controller) =
  var logLevel = LogLevel.DEBUG
  if(self.isDebugEnabled()):
    logLevel = LogLevel.INFO

  if(not self.nodeConfigurationService.setLogLevel(logLevel)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't toggle debug level"
    return

  self.delegate.onDebugToggled()

proc toggleCommunitiesPortalSection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.CommunitiesPortal))

proc toggleWalletSection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.Wallet))

proc toggleBrowserSection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.Browser))

proc toggleCommunitySection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.Community))

proc toggleNodeManagementSection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.NodeManagement))
