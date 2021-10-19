import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../../../../../app/boot/global_singleton

import ../../../../../app_service/service/about/service as about_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, aboutService: about_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, aboutService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("aboutModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method getAppVersion*[T](self: Module[T]): string =
  return self.controller.getAppVersion()

method getNodeVersion*[T](self: Module[T]): string =
  return self.controller.getNodeVersion()
