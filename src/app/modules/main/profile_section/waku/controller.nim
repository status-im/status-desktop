import chronicles
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../../../app_service/service/mailservers/service as mailservers_service

logScope:
  topics = "profile-section-waku-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    nodeConfigurationService: node_configuration_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.nodeConfigurationService = nodeConfigurationService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(mailservers_service.SIGNAL_ACTIVE_MAILSERVER_CHANGED) do(e: Args):
    let args = mailservers_service.ActiveMailserverChangedArgs(e)
    self.delegate.onActiveMailserverChanged(args.nodeId)

