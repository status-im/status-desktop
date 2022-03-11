import ./controller_interface
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/privacy/service as privacy_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    privacyService: privacy_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  privacyService: privacy_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.privacyService = privacyService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_MNEMONIC_REMOVAL) do(e: Args):
    self.delegate.onMnemonicUpdated()

  self.events.on(SIGNAL_PASSWORD_CHANGED) do(e: Args):
    var args = OperationSuccessArgs(e)
    self.delegate.onPasswordChanged(args.success)

method isMnemonicBackedUp*(self: Controller): bool =
  return self.privacyService.isMnemonicBackedUp()

method getLinkPreviewWhitelist*(self: Controller): string =
  return self.privacyService.getLinkPreviewWhitelist()

method changePassword*(self: Controller, password: string, newPassword: string) =
  self.privacyService.changePassword(password, newPassword)

method getMnemonic*(self: Controller): string =
  return self.privacyService.getMnemonic()

method removeMnemonic*(self: Controller) =
  self.privacyService.removeMnemonic()

method getMnemonicWordAtIndex*(self: Controller, index: int): string =
  return self.privacyService.getMnemonicWordAtIndex(index)

method getMessagesFromContactsOnly*(self: Controller): bool =
  return self.settingsService.getMessagesFromContactsOnly()

method setMessagesFromContactsOnly*(self: Controller, value: bool): bool =
  return self.settingsService.saveMessagesFromContactsOnly(value)

method validatePassword*(self: Controller, password: string): bool =
  return self.privacyService.validatePassword(password)

method getProfilePicturesShowTo*(self: Controller): int =
  self.settingsService.getProfilePicturesShowTo()

method setProfilePicturesShowTo*(self: Controller, value: int): bool =
  self.settingsService.saveProfilePicturesShowTo(value)

method getProfilePicturesVisibility*(self: Controller): int =
  self.settingsService.getProfilePicturesVisibility()

method setProfilePicturesVisibility*(self: Controller, value: int): bool =
  self.settingsService.saveProfilePicturesVisibility(value)

method getPasswordStrengthScore*(self: Controller, password: string): int = 
  return self.privacyService.getPasswordStrengthScore(password)