import io_interface
import uuids

import ../../../../../constants as main_constants
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/keychain/service as keychain_service
import ../../../../../app_service/service/privacy/service as privacy_service
import ../../../../../app_service/service/general/service as general_service
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

const UNIQUE_PRIVACY_SECTION_MODULE_AUTH_IDENTIFIER* = "PrivacySectionModule-Authentication"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    keychainService: keychain_service.Service
    privacyService: privacy_service.Service
    generalService: general_service.Service
    keychainConnectionIds: seq[UUID]

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service,
  keychainService: keychain_service.Service,
  privacyService: privacy_service.Service,
  generalService: general_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.keychainService = keychainService
  result.privacyService = privacyService
  result.generalService = generalService

proc delete*(self: Controller) =
  discard

proc disconnectKeychain*(self: Controller) =
  for id in self.keychainConnectionIds:
    self.events.disconnect(id)
  self.keychainConnectionIds = @[]

proc connectKeychain*(self: Controller) =
  var handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_SUCCESS) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.disconnectKeychain()
    self.delegate.onStoreToKeychainSuccess(args.data)
  self.keychainConnectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_ERROR) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.disconnectKeychain()
    self.delegate.onStoreToKeychainError(args.errDescription, args.errType)
  self.keychainConnectionIds.add(handlerId)

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_PRIVACY_SECTION_MODULE_AUTH_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.pin, args.password, args.keyUid)

  self.events.on(SIGNAL_MNEMONIC_REMOVED) do(e: Args):
    self.delegate.mnemonicBackedUp()

  self.events.on(SIGNAL_PASSWORD_CHANGED) do(e: Args):
    var args = OperationSuccessArgs(e)
    self.delegate.onPasswordChanged(args.success, args.errorMsg)

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

method getPasswordStrengthScore*(self: Controller, password, userName: string): int =
  return self.generalService.getPasswordStrengthScore(password, userName)

proc storeToKeychain*(self: Controller, data: string) =
  let myKeyUid = singletonInstance.userProfile.getKeyUid()
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if not main_constants.SUPPORTS_FINGERPRINT or # Dealing with Keychain is the MacOS only feature
    data.len == 0 or
    value == LS_VALUE_STORE or
    myKeyUid.len == 0:
      self.delegate.onStoreToKeychainError("", "")
      return
  self.connectKeychain()
  self.keychainService.storeData(myKeyUid, data)

proc removeFromKeychain*(self: Controller, key: string) =
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if not main_constants.IS_MACOS or # Dealing with Keychain is the MacOS only feature
    key.len == 0 or
    value != LS_VALUE_STORE:
      self.delegate.onStoreToKeychainError("", "")
      return
  self.connectKeychain()
  self.keychainService.tryToDeleteData(key)

proc authenticateLoggedInUser*(self: Controller) =
  var data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_PRIVACY_SECTION_MODULE_AUTH_IDENTIFIER)
  if singletonInstance.userProfile.getIsKeycardUser():
    data.keyUid = singletonInstance.userProfile.getKeyUid()
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc backupData*(self: Controller): int64 =
  return self.generalService.backupData()