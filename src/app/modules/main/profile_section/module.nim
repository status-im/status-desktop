import NimQml
import io_interface, view, controller
import ../../../global/global_singleton

import ../../../../app_service/service/profile/service as profile_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/about/service as about_service
import ../../../../app_service/service/language/service_interface as language_service
import ../../../../app_service/service/privacy/service as privacy_service
import ../../../../app_service/service/node_configuration/service_interface as node_configuration_service
import ../../../../app_service/service/devices/service as devices_service
import ../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../app_service/service/chat/service as chat_service

import ./profile/module as profile_module
import ./contacts/module as contacts_module
import ./language/module as language_module
import ./privacy/module as privacy_module
import ./about/module as about_module
import ./advanced/module as advanced_module
import ./devices/module as devices_module
import ./sync/module as sync_module
import ./notifications/module as notifications_module

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
    privacyModule: privacy_module.AccessInterface
    aboutModule: about_module.AccessInterface
    advancedModule: advanced_module.AccessInterface
    devicesModule: devices_module.AccessInterface
    syncModule: sync_module.AccessInterface
    notificationsModule: notifications_module.AccessInterface

proc newModule*[T](delegate: T,
  events: EventEmitter,
  accountsService: accounts_service.ServiceInterface,
  settingsService: settings_service.ServiceInterface,
  profileService: profile_service.ServiceInterface,
  contactsService: contacts_service.Service,
  aboutService: about_service.Service,
  languageService: language_service.ServiceInterface,
  privacyService: privacy_service.Service,
  nodeConfigurationService: node_configuration_service.ServiceInterface,
  devicesService: devices_service.Service,
  mailserversService: mailservers_service.Service,
  chatService: chat_service.Service
  ):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result)
  result.moduleLoaded = false

  result.profileModule = profile_module.newModule(result, profileService)
  result.contactsModule = contacts_module.newModule(result, events, contactsService, accountsService)
  result.languageModule = language_module.newModule(result, languageService)
  result.privacyModule = privacy_module.newModule(result, events, settingsService, privacyService)
  result.aboutModule = about_module.newModule(result, events, aboutService)
  result.advancedModule = advanced_module.newModule(result, events, settingsService, nodeConfigurationService)
  result.devicesModule = devices_module.newModule(result, events, settingsService, devicesService)
  result.syncModule = sync_module.newModule(result, events, settingsService, mailserversService)
  result.notificationsModule = notifications_module.newModule(result, events, chatService)

  singletonInstance.engine.setRootContextProperty("profileSectionModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.profileModule.delete
  self.contactsModule.delete
  self.languageModule.delete
  self.privacyModule.delete
  self.aboutModule.delete
  self.advancedModule.delete
  self.devicesModule.delete
  self.syncModule.delete

  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  self.view.load()
  self.profileModule.load()
  self.contactsModule.load()
  self.languageModule.load()
  self.privacyModule.load()
  self.aboutModule.load()
  self.advancedModule.load()
  self.devicesModule.load()
  self.syncModule.load()
  self.notificationsModule.load()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad[T](self: Module[T]) =
  if(not self.profileModule.isLoaded()):
    return

  if(not self.contactsModule.isLoaded()):
    return

  if(not self.languageModule.isLoaded()):
    return

  if(not self.privacyModule.isLoaded()):
    return

  if(not self.aboutModule.isLoaded()):
    return

  if(not self.advancedModule.isLoaded()):
    return

  if(not self.devicesModule.isLoaded()):
    return

  if(not self.syncModule.isLoaded()):
    return

  if(not self.notificationsModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.profileSectionDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method profileModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method getProfileModule*[T](self: Module[T]): QVariant =
  self.profileModule.getModuleAsVariant()

method contactsModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method languageModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method getLanguageModule*[T](self: Module[T]): QVariant =
  self.languageModule.getModuleAsVariant()

method privacyModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method getPrivacyModule*[T](self: Module[T]): QVariant =
  self.privacyModule.getModuleAsVariant()

method aboutModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method advancedModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method getAdvancedModule*[T](self: Module[T]): QVariant =
  self.advancedModule.getModuleAsVariant()

method devicesModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method getDevicesModule*[T](self: Module[T]): QVariant =
  self.devicesModule.getModuleAsVariant()

method syncModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method getSyncModule*[T](self: Module[T]): QVariant =
  self.syncModule.getModuleAsVariant()

method notificationsModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method getNotificationsModule*[T](self: Module[T]): QVariant =
  self.notificationsModule.getModuleAsVariant()