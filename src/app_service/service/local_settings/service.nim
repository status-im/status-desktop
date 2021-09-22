import NimQml, os, chronicles
import ../../../constants

# Local Account Settings keys:
const LS_KEY_STORE_TO_KEYCHAIN* = "storeToKeychain"
# Local Account Settings values:
const LS_VALUE_STORE* = "store"

const UNKNOWN_ACCOUNT = "unknownAccount"
const UNKNOWN_PROFILE = "unknownProfile"

logScope:
  topics = "local-settings"

QtObject:
  type LocalSettingsService* = ref object of QObject
    settingsFilePath: string
    settings: QSettings
    accountSettingsFilePath: string
    accountSettings: QSettings
    globalSettingsFilePath: string
    globalSettings: QSettings
    
  proc setup(self: LocalSettingsService) =
    self.settingsFilePath = os.joinPath(DATADIR, "qt", UNKNOWN_PROFILE)
    self.settings = newQSettings(self.settingsFilePath, QSettingsFormat.IniFormat)
    self.accountSettingsFilePath = os.joinPath(DATADIR, "qt", UNKNOWN_ACCOUNT)
    self.accountSettings = newQSettings(self.accountSettingsFilePath, QSettingsFormat.IniFormat)
    self.globalSettingsFilePath = os.joinPath(DATADIR, "qt", "global")
    self.globalSettings = newQSettings(self.globalSettingsFilePath, QSettingsFormat.IniFormat)
    self.QObject.setup

  proc delete*(self: LocalSettingsService) =
    self.settings.delete
    self.globalSettings.delete
    self.QObject.delete

  proc newLocalSettingsService*(): LocalSettingsService =
    new(result, delete)
    result.setup

  proc getGlobalSettingsFilePath*(self: LocalSettingsService): string =
    return self.globalSettingsFilePath

  proc getAccountSettingsFilePath*(self: LocalSettingsService): string =
    return self.accountSettingsFilePath

  proc getSettingsFilePath*(self: LocalSettingsService): string =
    return self.settingsFilePath

  proc updateSettingsFilePath*(self: LocalSettingsService, pubKey: string) =
    let unknownSettingsPath = os.joinPath(DATADIR, "qt", UNKNOWN_PROFILE)
    if (not unknownSettingsPath.tryRemoveFile):
      # Only fails if the file exists and an there was an error removing it
      # More info: https://nim-lang.org/docs/os.html#tryRemoveFile%2Cstring
      warn "Failed to remove unused settings file", file=unknownSettingsPath

    self.settings.delete
    self.settingsFilePath = os.joinPath(DATADIR, "qt", pubKey)
    self.settings = newQSettings(self.settingsFilePath, QSettingsFormat.IniFormat)

  proc updateAccountSettingsFilePath*(self: LocalSettingsService, alias: string) =
    let unknownAccountSettingsPath = os.joinPath(DATADIR, "qt", UNKNOWN_ACCOUNT)
    if (not unknownAccountSettingsPath.tryRemoveFile):
      # Only fails if the file exists and an there was an error removing it
      # More info: https://nim-lang.org/docs/os.html#tryRemoveFile%2Cstring
      warn "Failed to remove unused settings file", file=unknownAccountSettingsPath

    self.accountSettings.delete
    self.accountSettingsFilePath = os.joinPath(DATADIR, "qt", alias)
    self.accountSettings = newQSettings(self.accountSettingsFilePath, QSettingsFormat.IniFormat)

  proc setAccountValue*(self: LocalSettingsService, key: string, value: QVariant) =
    self.accountSettings.setValue(key, value)

  proc getAccountValue*(self: LocalSettingsService, key: string, 
    defaultValue: QVariant = newQVariant()): QVariant =
    self.accountSettings.value(key, defaultValue)

  proc removeAccountValue*(self: LocalSettingsService, key: string) =
    self.accountSettings.remove(key)

  proc setValue*(self: LocalSettingsService, key: string, value: QVariant) =
    self.settings.setValue(key, value)

  proc getValue*(self: LocalSettingsService, key: string, 
    defaultValue: QVariant = newQVariant()): QVariant =
    self.settings.value(key, defaultValue)
  
  proc removeValue*(self: LocalSettingsService, key: string) =
    self.settings.remove(key)

  proc setGlobalValue*(self: LocalSettingsService, key: string, value: QVariant) =
    self.globalSettings.setValue(key, value)

  proc getGlobalValue*(self: LocalSettingsService, key: string, 
    defaultValue: QVariant = newQVariant()): QVariant =
    self.globalSettings.value(key, defaultValue)
  
  proc removeGlobalValue*(self: LocalSettingsService, key: string) =
    self.globalSettings.remove(key)