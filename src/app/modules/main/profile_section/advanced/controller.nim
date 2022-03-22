import Tables, chronicles
import controller_interface
import io_interface

import ../../../../global/app_signals
import ../../../../core/eventemitter
import ../../../../core/fleets/fleet_configuration
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/stickers/service as stickers_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service

export controller_interface

logScope:
  topics = "profile-section-advanced-module-controller"

type
  Controller* = ref object of controller_interface.AccessInterface
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

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getCurrentNetworkDetails*(self: Controller): settings_service.Network =
  self.settingsService.getCurrentNetworkDetails()

method changeCurrentNetworkTo*(self: Controller, network: string) =
  if (not self.nodeConfigurationService.setNetwork(network)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't change network"
    return

  self.stickersService.clearRecentStickers()

  self.delegate.onCurrentNetworkSet()

method getFleet*(self: Controller): string =
  self.settingsService.getFleetAsString()

method changeFleetTo*(self: Controller, fleet: string) =
  if (not self.nodeConfigurationService.setFleet(fleet)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set fleet"
    return

  var wakuVersion = WAKU_VERSION_1
  if (fleet == $Fleet.WakuV2Prod or fleet == $Fleet.WakuV2Test or fleet == $Fleet.StatusTest or fleet == $Fleet.StatusProd):
    wakuVersion = WAKU_VERSION_2

  if (not self.nodeConfigurationService.setWakuVersion(wakuVersion)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set waku version for the fleet"
    return

  self.delegate.onFleetSet()

method getBloomLevel*(self: Controller): string =
  return self.nodeConfigurationService.getBloomLevel()

method setBloomLevel*(self: Controller, bloomLevel: string) =
  if (not self.nodeConfigurationService.setBloomLevel(bloomLevel)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set bloom level"
    return

  self.delegate.onBloomLevelSet()

method getWakuV2LightClientEnabled*(self: Controller): bool =
  return self.nodeConfigurationService.getV2LightMode()

method setWakuV2LightClientEnabled*(self: Controller, enabled: bool) =
  if (self.nodeConfigurationService.setV2LightMode(enabled)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't set WakuV2 light client"
    return

  self.delegate.onWakuV2LightClientSet()

method enableDeveloperFeatures*(self: Controller) =
  discard self.settingsService.saveTelemetryServerUrl(DEFAULT_TELEMETRY_SERVER_URL)
  discard self.settingsService.saveAutoMessageEnabled(true)
  discard self.nodeConfigurationService.setDebugLevel(LogLevel.DEBUG)

  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

method toggleTelemetry*(self: Controller) =
  var value = ""
  if(not self.isTelemetryEnabled()):
    value = DEFAULT_TELEMETRY_SERVER_URL

  if(not self.settingsService.saveTelemetryServerUrl(value)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't toggle telemetry message"
    return

  self.delegate.onTelemetryToggled()

method isTelemetryEnabled*(self: Controller): bool =
  return self.settingsService.getTelemetryServerUrl().len > 0

method toggleAutoMessage*(self: Controller) =
  let enabled = self.settingsService.autoMessageEnabled()
  if(not self.settingsService.saveAutoMessageEnabled(not enabled)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't toggle auto message"
    return

  self.delegate.onAutoMessageToggled()

method isAutoMessageEnabled*(self: Controller): bool =
  return self.settingsService.autoMessageEnabled()

method toggleDebug*(self: Controller) =
  var logLevel = LogLevel.DEBUG
  if(self.isDebugEnabled()):
    logLevel = LogLevel.INFO

  if(not self.nodeConfigurationService.setDebugLevel(logLevel)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't toggle debug level"
    return

  self.delegate.onDebugToggled()

method isDebugEnabled*(self: Controller): bool =
  return self.nodeConfigurationService.getDebugLevel() == $LogLevel.DEBUG

method getCustomNetworks*(self: Controller): seq[settings_service.Network] =
  return self.settingsService.getAvailableCustomNetworks()

method addCustomNetwork*(self: Controller, network: settings_service.Network) =
  if (not self.settingsService.addCustomNetwork(network)):
    # in the future we may do a call from here to show a popup about this error
    error "an error occurred, we couldn't add a custom network"
    return

  self.delegate.onCustomNetworkAdded(network)

method toggleWalletSection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.Wallet))

method toggleBrowserSection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.Browser))

method toggleCommunitySection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.Community))

method toggleNodeManagementSection*(self: Controller) =
  self.events.emit(TOGGLE_SECTION, ToggleSectionArgs(sectionType: SectionType.NodeManagement))
