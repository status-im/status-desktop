import NimQml
import macros
import typeinfo

proc mainProc() =
  var app = newQApplication()
  defer: app.delete()

  var engine = newQQmlApplicationEngine()
  defer: engine.delete()

  engine.load("main.qml")
  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
