import NimQml
import io_interface, view, controller
import ../../../../app/boot/global_singleton

import ../../../../app_service/service/profile/service as profile_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/about/service as about_service

import ./profile/module as profile_module
import ./contacts/module as contacts_module
import ./about/module as about_module

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

    profileModule: profile_module.AccessInterface
    contactsModule: contacts_module.AccessInterface
    aboutModule: about_module.AccessInterface

proc newModule*[T](delegate: T, accountsService: accounts_service.ServiceInterface, settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface, contactsService: contacts_service.ServiceInterface, aboutService: about_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView()
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, accountsService, settingsService, profileService)
  result.moduleLoaded = false

  result.profileModule = profile_module.newModule(result, accountsService, settingsService, profileService)
  result.contactsModule = contacts_module.newModule(result, contactsService, accountsService)
  result.aboutModule = about_module.newModule(result, aboutService)

  singletonInstance.engine.setRootContextProperty("profileSectionModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.profileModule.delete
  self.contactsModule.delete
  self.aboutModule.delete

  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  self.profileModule.load()
  self.contactsModule.load()
  self.aboutModule.load()

  self.moduleLoaded = true
  self.delegate.profileSectionDidLoad()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  discard
