import NimQml

import ../../app_service/service/local_settings/service as local_settings_service

QtObject:
  type LocalAccountSettings* = ref object of QObject
    localSettingsService: local_settings_service.Service
    
  proc setup(self: LocalAccountSettings) =
    self.QObject.setup

  proc delete*(self: LocalAccountSettings) =
    self.QObject.delete

  proc newLocalAccountSettings*(localSettingsService: local_settings_service.Service): 
    LocalAccountSettings =
    new(result, delete)
    result.setup
    result.localSettingsService = localSettingsService

  proc storeToKeychainValueChanged*(self: LocalAccountSettings) {.signal.}

  proc getStoreToKeychainValue(self: LocalAccountSettings): string {.slot.} =
    self.localSettingsService.getAccountValue(LS_KEY_STORE_TO_KEYCHAIN).stringVal

  proc setStoreToKeychainValue(self: LocalAccountSettings, value: string) {.slot.} =
    self.localSettingsService.setAccountValue(LS_KEY_STORE_TO_KEYCHAIN, 
    newQVariant(value))
    self.storeToKeychainValueChanged()

  QtProperty[string] storeToKeychainValue:
    read = getStoreToKeychainValue
    write = setStoreToKeychainValue
    notify = storeToKeychainValueChanged