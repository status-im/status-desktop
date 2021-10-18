import NimQml, os, chronicles
import ../../../constants

logScope:
  topics = "local-settings"

const UNKNOWN_PROFILE = "unknownProfile"

QtObject:
  type Service* = ref object of QObject
    settingsFilePath: string
    settings: QSettings
    globalSettingsFilePath: string
    globalSettings: QSettings
    
  proc setup(self: Service) =
    self.settingsFilePath = os.joinPath(DATADIR, "qt", UNKNOWN_PROFILE)
    self.settings = newQSettings(self.settingsFilePath, QSettingsFormat.IniFormat)
    self.globalSettingsFilePath = os.joinPath(DATADIR, "qt", "global")
    self.globalSettings = newQSettings(self.globalSettingsFilePath, QSettingsFormat.IniFormat)
    self.QObject.setup

  proc delete*(self: Service) =
    self.settings.delete
    self.globalSettings.delete
    self.QObject.delete

  proc newService*(): Service =
    new(result, delete)
    result.setup

  proc getGlobalSettingsFilePath*(self: Service): string =
    return self.globalSettingsFilePath

  proc getSettingsFilePath*(self: Service): string =
    return self.settingsFilePath

  proc updateSettingsFilePath*(self: Service, pubKey: string) =
    let unknownSettingsPath = os.joinPath(DATADIR, "qt", UNKNOWN_PROFILE)
    if (not unknownSettingsPath.tryRemoveFile):
      # Only fails if the file exists and an there was an error removing it
      # More info: https://nim-lang.org/docs/os.html#tryRemoveFile%2Cstring
      warn "Failed to remove unused settings file", file=unknownSettingsPath

    self.settings.delete
    self.settingsFilePath = os.joinPath(DATADIR, "qt", pubKey)
    self.settings = newQSettings(self.settingsFilePath, QSettingsFormat.IniFormat)

  proc setValue*(self: Service, key: string, value: QVariant) =
    self.settings.setValue(key, value)

  proc getValue*(self: Service, key: string, 
    defaultValue: QVariant = newQVariant()): QVariant =
    self.settings.value(key, defaultValue)
  
  proc removeValue*(self: Service, key: string) =
    self.settings.remove(key)

  proc setGlobalValue*(self: Service, key: string, value: QVariant) =
    self.globalSettings.setValue(key, value)

  proc getGlobalValue*(self: Service, key: string, 
    defaultValue: QVariant = newQVariant()): QVariant =
    self.globalSettings.value(key, defaultValue)
  
  proc removeGlobalValue*(self: Service, key: string) =
    self.globalSettings.remove(key)