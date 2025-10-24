import nimqml, json, chronicles

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/ens/service as ens_service

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

export io_interface

logScope:
  topics = "ens-resolver-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  ensService: ens_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = newController(result, ensService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.viewVariant.delete
  self.view.delete
  self.controller.delete()

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("browserSectionEnsResolver", self.viewVariant)

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true

method resolveEnsAddress*(self: Module, ensName: string): string =
  return self.controller.resolveEnsAddress(ensName)

method resolveEnsResourceUrl*(self: Module, ensName: string): string =
  let (scheme, host, path) = self.controller.resolveEnsResourceUrl(ensName)
  # Return as JSON string
  let result = %* {
    "scheme": scheme,
    "host": host,
    "path": path
  }
  return $result
