import chronicles
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/mailservers/service as mailservers_service
import
  ../../../../../app_service/service/node_configuration/service as
    node_configuration_service

logScope:
  topics = "profile-section-sync-module-controller"

type Controller* = ref object of RootObj
  delegate: io_interface.AccessInterface
  events: EventEmitter
  settingsService: settings_service.Service
  nodeConfigurationService: node_configuration_service.Service
  mailserversService: mailservers_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    mailserversService: mailservers_service.Service,
): Controller =
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
    self.delegate.onActiveMailserverChanged()

  self.events.on(SIGNAL_PINNED_MAILSERVER_CHANGED) do(e: Args):
    self.delegate.onPinnedMailserverChanged()

proc getAllMailservers*(
    self: Controller
): seq[tuple[name: string, nodeAddress: string]] =
  return self.mailserversService.getAllMailservers()

proc getPinnedMailserverId*(self: Controller): string =
  let fleet = self.nodeConfigurationService.getFleet()
  self.settingsService.getPinnedMailserverId(fleet)

proc setPinnedMailserverId*(self: Controller, mailserverID: string) =
  let fleet = self.nodeConfigurationService.getFleet()
  discard self.settingsService.setPinnedMailserverId(mailserverID, fleet)

proc getActiveMailserverId*(self: Controller): string =
  return self.mailserversService.getActiveMailserverId()

proc saveNewMailserver*(self: Controller, name: string, nodeAddress: string) =
  discard self.mailserversService.saveMailserver(name, nodeAddress)

proc enableAutomaticSelection*(self: Controller, value: bool) =
  self.mailserversService.enableAutomaticSelection(value)

proc getUseMailservers*(self: Controller): bool =
  return self.settingsService.getUseMailservers()

proc setUseMailservers*(self: Controller, value: bool): bool =
  return self.settingsService.toggleUseMailservers(value)
