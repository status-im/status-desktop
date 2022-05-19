import NimQml, chronicles, uuids
import io_interface
import ../io_interface as delegate_interface
import view, controller, custom_networks_model

import ../../../../../constants
import ../../../../core/eventemitter
import ../../../../global/global_singleton
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/stickers/service as stickers_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service

export io_interface

logScope:
  topics = "profile-section-advanced-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service,
  stickersService: stickers_service.Service,
  nodeConfigurationService: node_configuration_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, stickersService, nodeConfigurationService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  let customNetworks = self.controller.getCustomNetworks()
  for n in customNetworks:
    self.view.customNetworksModel().add(n.id, n.name)

  self.moduleLoaded = true
  self.delegate.advancedModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getCurrentNetworkName*(self: Module): string =
  return self.controller.getCurrentNetworkDetails().name

method getCurrentNetworkId*(self: Module): string =
  return self.controller.getCurrentNetworkDetails().id

method getCurrentChainId*(self: Module): int =
  return self.controller.getCurrentNetworkDetails().config.NetworkId

method setCurrentNetwork*(self: Module, network: string) =
  self.controller.changeCurrentNetworkTo(network)

method onCurrentNetworkSet*(self: Module) =
  info "quit the app because of successful network change"
  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

method getFleet*(self: Module): string =
  return self.controller.getFleet()

method setFleet*(self: Module, fleet: string) =
  self.controller.changeFleetTo(fleet)

method onFleetSet*(self: Module) =
  info "quit the app because of successful fleet change"
  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

method getLogDir*(self: Module): string =
  return url_fromLocalFile(constants.LOGDIR)

method getBloomLevel*(self: Module): string =
  return self.controller.getBloomLevel()

method setBloomLevel*(self: Module, bloomLevel: string) =
  self.controller.setBloomLevel(bloomLevel)

method onBloomLevelSet*(self: Module) =
  info "quit the app because of successful bloom level change"
  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

method getWakuV2LightClientEnabled*(self: Module): bool =
  return self.controller.getWakuV2LightClientEnabled()

method setWakuV2LightClientEnabled*(self: Module, enabled: bool) =
  self.controller.setWakuV2LightClientEnabled(enabled)

method onWakuV2LightClientSet*(self: Module) =
  info "quit the app because of successful WakuV2 light client change"
  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

method isTelemetryEnabled*(self: Module): bool =
  self.controller.isTelemetryEnabled()

method enableDeveloperFeatures*(self: Module) =
  self.controller.enableDeveloperFeatures()

method toggleTelemetry*(self: Module) =
  self.controller.toggleTelemetry()

method onTelemetryToggled*(self: Module) =
  self.view.emitTelemetryEnabledSignal()

method isAutoMessageEnabled*(self: Module): bool =
  self.controller.isAutoMessageEnabled()

method toggleAutoMessage*(self: Module) =
  self.controller.toggleAutoMessage()

method onAutoMessageToggled*(self: Module) =
  self.view.emitAutoMessageEnabledSignal()

method isDebugEnabled*(self: Module): bool =
  self.controller.isDebugEnabled()

method toggleDebug*(self: Module) =
  self.controller.toggleDebug()

method onDebugToggled*(self: Module) =
  self.view.isDebugEnabledChanged()

method addCustomNetwork*(self: Module, name: string, endpoint: string, networkId: int, networkType: string) =
  var network: settings_service.Network
  network.id = $genUUID()
  network.name = name
  network.config.NetworkId = networkId
  network.config.DataDir = "/ethereum/" & networkType
  network.config.UpstreamConfig.Enabled = true
  network.config.UpstreamConfig.URL = endpoint

  self.controller.addCustomNetwork(network)

method onCustomNetworkAdded*(self: Module, network: settings_service.Network) =
  self.view.customNetworksModel().add(network.id, network.name)

method toggleWalletSection*(self: Module) =
  self.controller.toggleWalletSection()

method toggleBrowserSection*(self: Module) =
  self.controller.toggleBrowserSection()

method toggleCommunitySection*(self: Module) =
  self.controller.toggleCommunitySection()

method toggleCommunitiesPortalSection*(self: Module) =
  self.controller.toggleCommunitiesPortalSection()

method toggleNodeManagementSection*(self: Module) =
  self.controller.toggleNodeManagementSection()

method onCommunityHistoryArchiveSupportToggled*(self: Module) =
  self.view.emitCommunityHistoryArchiveSupportEnabledSignal()

method toggleCommunityHistoryArchiveSupport*(self: Module) =
  self.controller.toggleCommunityHistoryArchiveSupport()

method isCommunityHistoryArchiveSupportEnabled*(self: Module): bool =
  self.controller.isCommunityHistoryArchiveSupportEnabled()
