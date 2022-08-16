import NimQml, chronicles

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import ../../../../core/eventemitter

import ../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

logScope:
  topics = "profile-section-profile-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    events: EventEmitter
    keycardService: keycard_service.Service
    walletAccountService: wallet_account_service.Service

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  walletAccountService: wallet_account_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.walletAccountService = walletAccountService
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events)
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
  self.delegate.profileModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant