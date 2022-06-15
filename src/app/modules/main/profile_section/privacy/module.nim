import NimQml, chronicles

import ../../../../../app/global/global_singleton

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/privacy/service as privacy_service
import ../../../../../app_service/service/general/service as general_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service,
  privacyService: privacy_service.Service,
  generalService: general_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, privacyService, generalService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.privacyModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getLinkPreviewWhitelist*(self: Module): string =
  return self.controller.getLinkPreviewWhitelist()

method changePassword*(self: Module, password: string, newPassword: string) =
  self.controller.changePassword(password, newPassword)

method isMnemonicBackedUp*(self: Module): bool =
  return self.controller.isMnemonicBackedUp()

method onMnemonicUpdated*(self: Module) =
  self.view.emitMnemonicBackedUpSignal()

method onPasswordChanged*(self: Module, success: bool, errorMsg: string) =
  self.view.emitPasswordChangedSignal(success, errorMsg)

method getMnemonic*(self: Module): string =
  self.controller.getMnemonic()

method removeMnemonic*(self: Module) =
  self.controller.removeMnemonic()

method getMnemonicWordAtIndex*(self: Module, index: int): string =
  return self.controller.getMnemonicWordAtIndex(index)

method getMessagesFromContactsOnly*(self: Module): bool =
  return self.controller.getMessagesFromContactsOnly()

method setMessagesFromContactsOnly*(self: Module, value: bool) =
  if(not self.controller.setMessagesFromContactsOnly(value)):
    error "an error occurred while saving messages from contacts only flag"

method validatePassword*(self: Module, password: string): bool =
  self.controller.validatePassword(password)

method getProfilePicturesShowTo*(self: Module): int =
  self.controller.getProfilePicturesShowTo()

method setProfilePicturesShowTo*(self: Module, value: int) =
  if (self.controller.setProfilePicturesShowTo(value)):
    self.view.profilePicturesShowToChanged()

method emitProfilePicturesShowToChanged*(self: Module, value: int) =
  self.view.profilePicturesShowToChanged()

method emitProfilePicturesVisibilityChanged*(self: Module, value: int) =
  self.view.profilePicturesVisibilityChanged()

method getProfilePicturesVisibility*(self: Module): int =
  self.controller.getProfilePicturesVisibility()

method setProfilePicturesVisibility*(self: Module, value: int) =
  if (self.controller.setProfilePicturesVisibility(value)):
    self.view.profilePicturesVisibilityChanged()

method getPasswordStrengthScore*(self: Module, password: string): int =
  return self.controller.getPasswordStrengthScore(password, singletonInstance.userProfile.getUsername())