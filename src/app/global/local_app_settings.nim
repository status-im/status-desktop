import NimQml, strutils, os

import ../../constants

# Local App Settings keys:
const LAS_KEY_LANGUAGE* = "global/language"
const DEFAULT_LOCALE = "en"
const LAS_KEY_THEME* = "global/theme"
const DEFAULT_THEME = 2 #system theme, from qml
const LAS_KEY_GEOMETRY = "global/app_geometry"
const LAS_KEY_VISIBILITY = "global/app_visibility"
const LAS_KEY_SCROLL_VELOCITY = "global/scroll_velocity"
const LAS_KEY_SCROLL_DECELERATION = "global/scroll_deceleration"
const DEFAULT_SCROLL_VELOCITY = 0 # unset
const DEFAULT_SCROLL_DECELERATION = 0 # unset
const LAS_KEY_CUSTOM_MOUSE_SCROLLING_ENABLED = "global/custom_mouse_scroll_enabled"
const DEFAULT_CUSTOM_MOUSE_SCROLLING_ENABLED = false
const DEFAULT_VISIBILITY = 2 #windowed visibility, from qml
const LAS_KEY_FAKE_LOADING_SCREEN_ENABLED = "global/fake_loading_screen"
let DEFAULT_FAKE_LOADING_SCREEN_ENABLED = defined(production) and not TEST_MODE_ENABLED #enabled in production, disabled in development and e2e tests
const LAS_KEY_SHARDED_COMMUNITIES_ENABLED = "global/sharded_communities"
const DEFAULT_LAS_KEY_SHARDED_COMMUNITIES_ENABLED = false

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

  proc isCustomMouseScrollingEnabledChanged*(self: LocalAppSettings) {.signal.}
  proc getCustomMouseScrollingEnabled*(self: LocalAppSettings): bool {.slot.} =
    self.settings.value(LAS_KEY_CUSTOM_MOUSE_SCROLLING_ENABLED, newQVariant(DEFAULT_CUSTOM_MOUSE_SCROLLING_ENABLED)).boolVal
  proc setCustomMouseScrollingEnabled*(self: LocalAppSettings, value: bool) {.slot.} =
    self.settings.setValue(LAS_KEY_CUSTOM_MOUSE_SCROLLING_ENABLED, newQVariant(value))
    self.isCustomMouseScrollingEnabledChanged()

  QtProperty[bool] isCustomMouseScrollingEnabled:
    read = getCustomMouseScrollingEnabled
    write = setCustomMouseScrollingEnabled
    notify = isCustomMouseScrollingEnabledChanged

  proc scrollVelocityChanged*(self: LocalAppSettings) {.signal.}
  proc getScrollVelocity*(self: LocalAppSettings): int {.slot.} =
    self.settings.value(LAS_KEY_SCROLL_VELOCITY, newQVariant(DEFAULT_SCROLL_VELOCITY)).intVal
  proc setScrollVelocity*(self: LocalAppSettings, value: int) {.slot.} =
    self.settings.setValue(LAS_KEY_SCROLL_VELOCITY, newQVariant(value))
    self.scrollVelocityChanged()

  QtProperty[int] scrollVelocity:
    read = getScrollVelocity
    write = setScrollVelocity
    notify = scrollVelocityChanged

  proc scrollDecelerationChanged*(self: LocalAppSettings) {.signal.}
  proc getScrollDeceleration*(self: LocalAppSettings): int {.slot.} =
    self.settings.value(LAS_KEY_SCROLL_DECELERATION, newQVariant(DEFAULT_SCROLL_DECELERATION)).intVal
  proc setScrollDeceleration*(self: LocalAppSettings, value: int) {.slot.} =
    self.settings.setValue(LAS_KEY_SCROLL_DECELERATION, newQVariant(value))
    self.scrollDecelerationChanged()

  QtProperty[int] scrollDeceleration:
    read = getScrollDeceleration
    write = setScrollDeceleration
    notify = scrollDecelerationChanged

  proc removeKey*(self: LocalAppSettings, key: string) =
    if(self.settings.isNil):
      return

    self.settings.remove(key)

    case key:
      of LAS_KEY_LANGUAGE: self.languageChanged()
      of LAS_KEY_THEME: self.themeChanged()
      of LAS_KEY_GEOMETRY: self.geometryChanged()
      of LAS_KEY_VISIBILITY: self.visibilityChanged()
      of LAS_KEY_SCROLL_VELOCITY: self.scrollVelocityChanged()
      of LAS_KEY_SCROLL_DECELERATION: self.scrollDecelerationChanged()
      of LAS_KEY_CUSTOM_MOUSE_SCROLLING_ENABLED: self.isCustomMouseScrollingEnabledChanged()


  proc getTestEnvironment*(self: LocalAppSettings): bool {.slot.} =
    return TEST_MODE_ENABLED

  QtProperty[bool] testEnvironment:
    read = getTestEnvironment

  proc fakeLoadingScreenEnabledChanged*(self: LocalAppSettings) {.signal.}
  proc getFakeLoadingScreenEnabled*(self: LocalAppSettings): bool {.slot.} =
    self.settings.value(LAS_KEY_FAKE_LOADING_SCREEN_ENABLED, newQVariant(DEFAULT_FAKE_LOADING_SCREEN_ENABLED)).boolVal

  proc setFakeLoadingScreenEnabled*(self: LocalAppSettings, enabled: bool) {.slot.} =
    self.settings.setValue(LAS_KEY_FAKE_LOADING_SCREEN_ENABLED, newQVariant(enabled))
    self.fakeLoadingScreenEnabledChanged()

  QtProperty[bool] fakeLoadingScreenEnabled:
    read = getFakeLoadingScreenEnabled
    write = setFakeLoadingScreenEnabled
    notify = fakeLoadingScreenEnabledChanged

  proc wakuV2ShardedCommunitiesEnabledChanged*(self: LocalAppSettings) {.signal.}
  proc getWakuV2ShardedCommunitiesEnabled*(self: LocalAppSettings): bool {.slot.} =
    self.settings.value(LAS_KEY_SHARDED_COMMUNITIES_ENABLED, newQVariant(DEFAULT_LAS_KEY_SHARDED_COMMUNITIES_ENABLED)).boolVal

  proc setWakuV2ShardedCommunitiesEnabled*(self: LocalAppSettings, enabled: bool) {.slot.} =
    self.settings.setValue(LAS_KEY_SHARDED_COMMUNITIES_ENABLED, newQVariant(enabled))
    self.wakuV2ShardedCommunitiesEnabledChanged()

  QtProperty[bool] wakuV2ShardedCommunitiesEnabled:
    read = getWakuV2ShardedCommunitiesEnabled
    write = setWakuV2ShardedCommunitiesEnabled
    notify = wakuV2ShardedCommunitiesEnabledChanged
