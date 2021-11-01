import NimQml, Tables
import json, sequtils
import status/settings
import status/types/[setting]
import status/status

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton
import ../../../../../app_service/service/settings/service as settings_service

export io_interface


type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, settingsService: settings_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, settingsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("fleetsModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  let fleet = self.controller.getFleet()
  self.view.setFleet(fleet)

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method getFleet*[T](self: Module[T]): string =
  self.controller.getFleet()

method setFleet*[T](self: Module[T], newFleet: string) =
  self.controller.setFleet(newFleet)