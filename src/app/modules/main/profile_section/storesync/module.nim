import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton

import ../../../../../app_service/service/syncnode/service as syncnode_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, syncnodeService: syncnode_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, syncnodeService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("storeSyncModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

# TODO: this is async
method getActiveMailserver*[T](self: Module[T]): string =
  return self.controller.getActiveMailserver()

method getAutomaticSelection*[T](self: Module[T]): bool =
  return self.controller.getAutomaticSelection()

method pinMailserver*[T](self: Module[T], id: string) =
  self.controller.pinMailserver(id)

method enableAutomaticSelection*[T](self: Module[T], value: bool) =
  self.controller.enableAutomaticSelection(value)

method saveMailserver*[T](self: Module[T], name: string, address: string) =
  self.controller.saveMailserver(name, address)
