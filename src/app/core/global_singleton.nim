import NimQml

import local_account_settings as local_acc_settings

export local_acc_settings

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

proc delete*(self: GlobalSingleton) =
  self.engine.delete()
  self.localAccountSettings.delete()