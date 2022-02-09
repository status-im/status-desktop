import NimQml, os

import ../../constants

# Local App Settings keys:
const LAS_KEY_LOCALE* = "global/locale"
const DEFAULT_LOCALE = "en"
const LAS_KEY_THEME* = "global/theme"
const DEFAULT_THEME = 2 #system theme, from qml
const LAS_KEY_APP_WIDTH = "global/app_width"
const DEFAULT_APP_WIDTH = 1232
const LAS_KEY_APP_HEIGHT = "global/app_height"
const DEFAULT_APP_HEIGHT = 770
const LAS_KEY_APP_SIZE_INITIALIZED = "global/app_size_initialized"
const DEFAULT_APP_SIZE_INITIALIZED = false

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


  proc localeChanged*(self: LocalAppSettings) {.signal.}
  proc getLocale*(self: LocalAppSettings): string {.slot.} =
    self.settings.value(LAS_KEY_LOCALE, newQVariant(DEFAULT_LOCALE)).stringVal
  proc setLocale*(self: LocalAppSettings, value: string) {.slot.} =
    self.settings.setValue(LAS_KEY_LOCALE, newQVariant(value))
    self.localeChanged()

  QtProperty[string] locale:
    read = getLocale
    write = setLocale
    notify = localeChanged


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

  proc appWidthChanged*(self: LocalAppSettings) {.signal.}
  proc getAppWidth*(self: LocalAppSettings): int {.slot.} =
    self.settings.value(LAS_KEY_APP_WIDTH, newQVariant(DEFAULT_APP_WIDTH)).intVal
  proc setAppWidth*(self: LocalAppSettings, value: int) {.slot.} =
    self.settings.setValue(LAS_KEY_APP_WIDTH, newQVariant(value))
    self.appWidthChanged()

  QtProperty[int] appWidth:
    read = getAppWidth
    write = setAppWidth
    notify = appWidthChanged

  proc appHeightChanged*(self: LocalAppSettings) {.signal.}
  proc getAppHeight*(self: LocalAppSettings): int {.slot.} =
    self.settings.value(LAS_KEY_APP_HEIGHT, newQVariant(DEFAULT_APP_HEIGHT)).intVal
  proc setAppHeight*(self: LocalAppSettings, value: int) {.slot.} =
    self.settings.setValue(LAS_KEY_APP_HEIGHT, newQVariant(value))
    self.appHeightChanged()

  QtProperty[int] appHeight:
    read = getAppHeight
    write = setAppHeight
    notify = appHeightChanged

  proc appSizeInitializedChanged*(self: LocalAppSettings) {.signal.}
  proc isAppSizeInitialized*(self: LocalAppSettings): bool {.slot.} =
    self.settings.value(LAS_KEY_APP_SIZE_INITIALIZED, newQVariant(DEFAULT_APP_SIZE_INITIALIZED)).boolVal
  proc setAppSizeInitialized*(self: LocalAppSettings, value: bool) {.slot.} =
    self.settings.setValue(LAS_KEY_APP_SIZE_INITIALIZED, newQVariant(value))
    self.appSizeInitializedChanged()

  QtProperty[bool] appSizeInitialized:
    read = isAppSizeInitialized
    write = setAppSizeInitialized
    notify = appSizeInitializedChanged

  proc removeKey*(self: LocalAppSettings, key: string) =
    if(self.settings.isNil):
      return

    self.settings.remove(key)

    case key:
      of LAS_KEY_LOCALE: self.localeChanged()
      of LAS_KEY_THEME: self.themeChanged()
