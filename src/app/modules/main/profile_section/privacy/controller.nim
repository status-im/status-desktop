import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/privacy/service as privacy_service
import ../../../../../app_service/service/general/service as general_service


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    privacyService: privacy_service.Service
    generalService: general_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter,

  settingsService: settings_service.Service,
  privacyService: privacy_service.Service,
  generalService: general_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.privacyService = privacyService
  result.generalService = generalService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_MNEMONIC_REMOVAL) do(e: Args):
    self.delegate.onMnemonicUpdated()

  self.events.on(SIGNAL_PASSWORD_CHANGED) do(e: Args):
    var args = OperationSuccessArgs(e)
    self.delegate.onPasswordChanged(args.success, args.errorMsg)

  self.events.on(SIGNAL_SETTING_PROFILE_PICTURES_SHOW_TO_CHANGED) do(e: Args):
    var args = SettingProfilePictureArgs(e)
    self.delegate.emitProfilePicturesShowToChanged(args.value)

  self.events.on(SIGNAL_SETTING_PROFILE_PICTURES_VISIBILITY_CHANGED) do(e: Args):
    var args = SettingProfilePictureArgs(e)
    self.delegate.emitProfilePicturesVisibilityChanged(args.value)

proc isMnemonicBackedUp*(self: Controller): bool =
  return self.privacyService.isMnemonicBackedUp()

proc getLinkPreviewWhitelist*(self: Controller): string =
  return self.privacyService.getLinkPreviewWhitelist()

proc changePassword*(self: Controller, password: string, newPassword: string) =
  self.privacyService.changePassword(password, newPassword)

proc getMnemonic*(self: Controller): string =
  return self.privacyService.getMnemonic()

proc removeMnemonic*(self: Controller) =
  self.privacyService.removeMnemonic()

proc getMnemonicWordAtIndex*(self: Controller, index: int): string =
  return self.privacyService.getMnemonicWordAtIndex(index)

proc getMessagesFromContactsOnly*(self: Controller): bool =
  return self.settingsService.getMessagesFromContactsOnly()

proc setMessagesFromContactsOnly*(self: Controller, value: bool): bool =
  return self.settingsService.saveMessagesFromContactsOnly(value)

proc validatePassword*(self: Controller, password: string): bool =
  return self.privacyService.validatePassword(password)

proc getProfilePicturesShowTo*(self: Controller): int =
  self.settingsService.getProfilePicturesShowTo()

proc setProfilePicturesShowTo*(self: Controller, value: int): bool =
  self.settingsService.saveProfilePicturesShowTo(value)

proc getProfilePicturesVisibility*(self: Controller): int =
  self.settingsService.getProfilePicturesVisibility()

proc setProfilePicturesVisibility*(self: Controller, value: int): bool =
  self.settingsService.saveProfilePicturesVisibility(value)

method getPasswordStrengthScore*(self: Controller, password, userName: string): int = 
  return self.generalService.getPasswordStrengthScore(password, userName)

