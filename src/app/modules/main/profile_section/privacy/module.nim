import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton

import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/privacy/service as privacy_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, privacyService: privacy_service.ServiceInterface, accountsService: accounts_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, privacyService, accountsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("privacyModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method getLinkPreviewWhitelist*[T](self: Module[T]): string =
  return self.controller.getLinkPreviewWhitelist()

method changePassword*[T](self: Module[T], password: string, newPassword: string): bool =
  return self.controller.changePassword(password, newPassword)
