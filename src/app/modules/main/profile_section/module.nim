import NimQml
import io_interface, view, controller
import ../../../core/global_singleton

import ../../../../app_service/service/profile/service as profile_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/about/service as about_service
import ../../../../app_service/service/language/service as language_service
import ../../../../app_service/service/mnemonic/service as mnemonic_service

import ./profile/module as profile_module
import ./contacts/module as contacts_module
import ./language/module as language_module
import ./mnemonic/module as mnemonic_module
import ./about/module as about_module

import eventemitter

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

    profileModule: profile_module.AccessInterface
    languageModule: language_module.AccessInterface
    contactsModule: contacts_module.AccessInterface
    mnemonicModule: mnemonic_module.AccessInterface
    aboutModule: about_module.AccessInterface

proc newModule*[T](delegate: T,
  events: EventEmitter,
  accountsService: accounts_service.ServiceInterface,
  settingsService: settings_service.ServiceInterface,
  profileService: profile_service.ServiceInterface,
  contactsService: contacts_service.ServiceInterface,
  aboutService: about_service.ServiceInterface,
  languageService: language_service.ServiceInterface,
  mnemonicService: mnemonic_service.ServiceInterface
  ):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView()
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, accountsService, settingsService, profileService, languageService, mnemonicService)
  result.moduleLoaded = false

  result.profileModule = profile_module.newModule(result, accountsService, settingsService, profileService)
  result.contactsModule = contacts_module.newModule(result, events, contactsService, accountsService)
  result.languageModule = language_module.newModule(result, languageService)
  result.mnemonicModule = mnemonic_module.newModule(result, mnemonicService)
  result.aboutModule = about_module.newModule(result, aboutService)

  singletonInstance.engine.setRootContextProperty("profileSectionModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.profileModule.delete
  self.contactsModule.delete
  self.languageModule.delete
  self.mnemonicModule.delete
  self.aboutModule.delete

  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  self.profileModule.load()
  self.contactsModule.load()
  self.languageModule.load()
  self.mnemonicModule.load()
  self.aboutModule.load()

  self.moduleLoaded = true
  self.delegate.profileSectionDidLoad()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  discard
