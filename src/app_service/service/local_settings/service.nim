import NimQml, os, chronicles
import ../../../constants

# Local Settings keys:
const LS_KEY_STORE_TO_KEYCHAIN* = "storeToKeychain"
# Local Settings values:
const LS_VALUE_STORE* = "store"

const UNKNOWN_ACCOUNT = "unknownAccount"

logScope:
  topics = "local-settings"

QtObject:
  type LocalSettingsService* = ref object of QObject
    settingsFilePath: string
    settings: QSettings
    globalSettingsFilePath: string
    globalSettings: QSettings
    
  proc setup(self: LocalSettingsService) =
    self.settingsFilePath = os.joinPath(DATADIR, "qt", UNKNOWN_ACCOUNT)
    self.settings = newQSettings(self.settingsFilePath, QSettingsFormat.IniFormat)
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

  proc getSettingsFilePath*(self: LocalSettingsService): string =
    return self.settingsFilePath

  proc updateSettingsFilePath*(self: LocalSettingsService, pubKey: string) =
    let unknownSettingsPath = os.joinPath(DATADIR, "qt", UNKNOWN_ACCOUNT)
    if (not unknownSettingsPath.tryRemoveFile):
      # Only fails if the file exists and an there was an error removing it
      # More info: https://nim-lang.org/docs/os.html#tryRemoveFile%2Cstring
      warn "Failed to remove unused settings file", file=unknownSettingsPath

    self.settings.delete
    self.settingsFilePath = os.joinPath(DATADIR, "qt", pubKey)
    self.settings = newQSettings(self.settingsFilePath, QSettingsFormat.IniFormat)

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