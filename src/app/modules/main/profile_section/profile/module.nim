import NimQml, Tables

import ./io_interface, ./view, ./controller, ./item
import ../../../../../app/boot/global_singleton

import ../../../../../app_service/service/profile/service as profile_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/settings/service as settings_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, accountsService: accounts_service.ServiceInterface, settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = result.view.getModel
  result.controller = controller.newController[Module[T]](result, accountsService, settingsService, profileService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("profileModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  let profile = self.controller.getProfile()
  self.view.setProfile(profile)
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded
