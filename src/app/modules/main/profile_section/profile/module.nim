import NimQml, Tables

import ./io_interface, ./view, ./controller, ./item
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../../app_service/service/profile/service as profile_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/settings/service_interface as settings_service

import status/types/identity_image

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, accountsService: accounts_service.ServiceInterface, 
  settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, accountsService, settingsService, profileService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("profileModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()
  
method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  let profile = self.controller.getProfile()
  self.view.setProfile(profile)
  
  self.moduleLoaded = true
  self.delegate.profileModuleDidLoad()

method storeIdentityImage*(self: Module, address: string, image: string, aX: int, aY: int, bX: int, bY: int): identity_image.IdentityImage =
  self.controller.storeIdentityImage(address, image, aX, aY, bX, bY)

method deleteIdentityImage*(self: Module, address: string): string =
  self.controller.deleteIdentityImage(address)
