import NimQml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller

import ../../../../../constants
import ../../../../global/global_singleton
import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/node_configuration/service_interface as node_configuration_service

export io_interface

logScope:
  topics = "profile-section-advanced-module"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, settingsService: settings_service.ServiceInterface,
  nodeConfigurationService: node_configuration_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, settingsService, nodeConfigurationService)
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
  self.moduleLoaded = true
  self.delegate.advancedModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getCurrentNetworkName*(self: Module): string =
  return self.controller.getCurrentNetworkDetails().name

method getCurrentNetworkId*(self: Module): string =
  return self.controller.getCurrentNetworkDetails().id
  
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
  info "quit the app because of successful debug level changed"
  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

  