import NimQml

import local_account_settings
import local_account_sensitive_settings
import local_app_settings
import user_profile
import utils
import global_events

export local_account_settings
export local_account_sensitive_settings
export local_app_settings
export user_profile
export utils
export global_events

type
  GlobalSingleton = object
  # Don't export GlobalSingleton type.
  # Other global things like local/global settings will be added here.

var singletonInstance* = GlobalSingleton()

proc engine*(self: GlobalSingleton): QQmlApplicationEngine =
  var qmlEngine {.global.}: QQmlApplicationEngine
  if (qmlEngine.isNil):
    qmlEngine = newQQmlApplicationEngine()
  return qmlEngine

proc localAccountSettings*(self: GlobalSingleton): LocalAccountSettings =
  var localAccountSettings {.global.}: LocalAccountSettings
  if (localAccountSettings.isNil):
    localAccountSettings = newLocalAccountSettings()
  return localAccountSettings

proc localAccountSensitiveSettings*(self: GlobalSingleton): LocalAccountSensitiveSettings =
  var localAccountSensitiveSettings {.global.}: LocalAccountSensitiveSettings
  if (localAccountSensitiveSettings.isNil):
    localAccountSensitiveSettings = newLocalAccountSensitiveSettings()
  return localAccountSensitiveSettings

proc localAppSettings*(self: GlobalSingleton): LocalAppSettings =
  var localAppSettings {.global.}: LocalAppSettings
  if (localAppSettings.isNil):
    localAppSettings = newLocalAppSettings("global")
  return localAppSettings

proc userProfile*(self: GlobalSingleton): UserProfile =
  var userProfile {.global.}: UserProfile
  if (userProfile.isNil):
    userProfile = newUserProfile(singletonInstance.localAccountSettings)
  return userProfile

proc utils*(self: GlobalSingleton): Utils =
  var utils {.global.}: Utils
  if (utils.isNil):
    utils = newUtils()
  return utils

proc globalEvents*(self: GlobalSingleton): GlobalEvents =
  var globalEvents {.global.}: GlobalEvents
  if (globalEvents.isNil):
    globalEvents = newGlobalEvents()
  return globalEvents

proc delete*(self: GlobalSingleton) =
  self.engine.delete()
  self.localAccountSettings.delete()
  self.localAccountSensitiveSettings.delete()
  self.localAppSettings.delete()
  self.userProfile.delete()
