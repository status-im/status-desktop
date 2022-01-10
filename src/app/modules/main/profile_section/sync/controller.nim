import Tables, chronicles
import controller_interface
import io_interface

import ../../../../core/eventemitter
import ../../../../core/fleets/fleet_configuration
import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/mailservers/service as mailservers_service

export controller_interface

logScope:
  topics = "profile-section-sync-module-controller"

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    mailserversService: mailservers_service.Service
    
proc newController*(delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  mailserversService: mailservers_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.mailserversService = mailserversService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_ACTIVE_MAILSERVER_CHANGED) do(e: Args):
    var args = ActiveMailserverChangedArgs(e)
    self.delegate.onActiveMailserverChanged(args.nodeAddress)

method getAllMailservers*(self: Controller): seq[tuple[name: string, nodeAddress: string]] = 
  return self.mailserversService.getAllMailservers()

method getPinnedMailserver*(self: Controller): string =
  let fleet = self.settingsService.getFleet()
  self.settingsService.getPinnedMailserver(fleet)

method pinMailserver*(self: Controller, nodeAddress: string) =
  let fleet = self.settingsService.getFleet()
  discard self.settingsService.pinMailserver(nodeAddress, fleet)

method saveNewMailserver*(self: Controller, name: string, nodeAddress: string) =
  self.mailserversService.saveMailserver(name, nodeAddress)

method enableAutomaticSelection*(self: Controller, value: bool) =
  self.mailserversService.enableAutomaticSelection(value)