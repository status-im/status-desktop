import NimQml, Tables

import ./io_interface, ./view, ./controller, ./item
import ../../../../../app/boot/global_singleton

import ../../../../../app_service/service/contacts/service as contacts_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, contactsService: accounts_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  # result.viewVariant = result.view.getModel
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, contactsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("contactsModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
#   let profile = self.controller.getProfile()
#   self.view.setProfile(profile)
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded
