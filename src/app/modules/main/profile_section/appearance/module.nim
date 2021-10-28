import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton

import ../../../../../app_service/service/appearance/service as appearance_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, appearanceService: appearance_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, appearanceService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("appearanceModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method readTextFile*[T](self: Module[T], fileName: string): string =
  return self.controller.readTextFile(fileName)

method writeTextFile*[T](self: Module[T], path: string, text: string) =
  self.controller.writeTextFile(path, text)
