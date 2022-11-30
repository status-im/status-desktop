import Tables, chronicles
import io_interface

import ../../../../core/eventemitter
import ../../../../core/fleets/fleet_configuration
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service

logScope:
  topics = "profile-section-sync-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    nodeConfigurationService: node_configuration_service.Service
    mailserversService: mailservers_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  mailserversService: mailservers_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.nodeConfigurationService = nodeConfigurationService
  result.mailserversService = mailserversService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_ACTIVE_MAILSERVER_CHANGED) do(e: Args):
    var args = ActiveMailserverChangedArgs(e)
    self.delegate.onActiveMailserverChanged(args.nodeAddress)

proc getAllMailservers*(self: Controller): seq[tuple[name: string, nodeAddress: string]] =
  return self.mailserversService.getAllMailservers()

proc getPinnedMailserver*(self: Controller): string =
  let fleet = self.nodeConfigurationService.getFleet()
  self.settingsService.getPinnedMailserver(fleet)

proc pinMailserver*(self: Controller, mailserverID: string) =
  let fleet = self.nodeConfigurationService.getFleet()
  discard self.settingsService.pinMailserver(mailserverID, fleet)

proc saveNewMailserver*(self: Controller, name: string, nodeAddress: string) =
  discard self.mailserversService.saveMailserver(name, nodeAddress)

proc enableAutomaticSelection*(self: Controller, value: bool) =
  self.mailserversService.enableAutomaticSelection(value)

method getUseMailservers*(self: Controller): bool =
  return self.settingsService.getUseMailservers()

method setUseMailservers*(self: Controller, value: bool): bool =
  return self.settingsService.saveUseMailservers(value)