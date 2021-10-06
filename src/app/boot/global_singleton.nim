import NimQml

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

proc delete*(self: GlobalSingleton) =
  self.engine.delete()