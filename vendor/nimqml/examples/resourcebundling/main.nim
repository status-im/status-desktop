import nimqml

proc mainProc() =
  let app = newQApplication()
  defer: app.delete
  let engine = newQQmlApplicationEngine()
  defer: engine.delete
  let appDirPath = app.applicationDirPath & "/" & "main.rcc"
  QResource.registerResource(appDirPath)
  engine.load(newQUrl("qrc:///main.qml"))

  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
