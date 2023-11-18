import chronicles
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service

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
  discard

proc getAllWakuNodes*(self: Controller): seq[string] =
  return self.nodeConfigurationService.getAllWakuNodes()

proc saveNewWakuNode*(self: Controller, nodeAddress: string) =
  self.nodeConfigurationService.saveNewWakuNode(nodeAddress)
