import NimQml, os

import ../../constants

# Local App Settings keys:
const LAS_KEY_LANGUAGE* = "global/language"
const DEFAULT_LOCALE = "en"
const LAS_KEY_THEME* = "global/theme"
const DEFAULT_THEME = 2 #system theme, from qml
const LAS_KEY_GEOMETRY = "global/app_geometry"
const LAS_KEY_VISIBILITY = "global/app_visibility"
const DEFAULT_VISIBILITY = 2 #windowed visibility, from qml

QtObject:
  type LocalAppSettings* = ref object of QObject
    settings: QSettings

  proc setup(self: LocalAppSettings) =
    self.QObject.setup

  proc delete*(self: LocalAppSettings) =
    self.settings.delete

    self.QObject.delete

  proc newLocalAppSettings*(fileName: string): LocalAppSettings =
    new(result, delete)
    result.setup
    let filePath = os.joinPath(DATADIR, "qt", fileName)
    result.settings = newQSettings(filePath, QSettingsFormat.IniFormat)


  proc languageChanged*(self: LocalAppSettings) {.signal.}
  proc getLanguage*(self: LocalAppSettings): string {.slot.} =
    self.settings.value(LAS_KEY_LANGUAGE, newQVariant(DEFAULT_LOCALE)).stringVal
  proc setLanguage*(self: LocalAppSettings, value: string) {.slot.} =
    self.settings.setValue(LAS_KEY_LANGUAGE, newQVariant(value))
    self.languageChanged()

  QtProperty[string] language:
    read = getLanguage
    write = setLanguage
    notify = languageChanged


  proc themeChanged*(self: LocalAppSettings) {.signal.}
  proc getTheme*(self: LocalAppSettings): int {.slot.} =
    self.settings.value(LAS_KEY_THEME, newQVariant(DEFAULT_THEME)).intVal
  proc setTheme*(self: LocalAppSettings, value: int) {.slot.} =
    self.settings.setValue(LAS_KEY_THEME, newQVariant(value))
    self.themeChanged()

  QtProperty[int] theme:
    read = getTheme
    write = setTheme
    notify = themeChanged


  proc geometryChanged*(self: LocalAppSettings) {.signal.}
  proc getGeometry*(self: LocalAppSettings): QVariant {.slot.} =
    self.settings.value(LAS_KEY_GEOMETRY)
  proc setGeometry*(self: LocalAppSettings, value: QVariant) {.slot.} =
    self.settings.setValue(LAS_KEY_GEOMETRY, newQVariant(value))
    self.geometryChanged()

  QtProperty[QVariant] geometry:
    read = getGeometry
    write = setGeometry
    notify = geometryChanged


  proc visibilityChanged*(self: LocalAppSettings) {.signal.}
  proc getVisibility*(self: LocalAppSettings): int {.slot.} =
    self.settings.value(LAS_KEY_VISIBILITY, newQVariant(DEFAULT_VISIBILITY)).intVal
  proc setVisibility*(self: LocalAppSettings, value: int) {.slot.} =
    self.settings.setValue(LAS_KEY_VISIBILITY, newQVariant(value))
    self.visibilityChanged()

  QtProperty[int] visibility:
    read = getVisibility
    write = setVisibility
    notify = visibilityChanged


  proc removeKey*(self: LocalAppSettings, key: string) =
    if(self.settings.isNil):
      return

    self.settings.remove(key)

    case key:
      of LAS_KEY_LANGUAGE: self.languageChanged()
      of LAS_KEY_THEME: self.themeChanged()
      of LAS_KEY_GEOMETRY: self.geometryChanged()
      of LAS_KEY_VISIBILITY: self.visibilityChanged()


  proc getTestEnvironment*(self: LocalAppSettings): bool {.slot.} =
    return existsEnv(TEST_ENVIRONMENT_VAR)

  QtProperty[bool] testEnvironment:
    read = getTestEnvironment