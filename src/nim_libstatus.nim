import NimQml
import applicationLogic

proc mainProc() =
  var app = newQApplication()
  defer: app.delete()

  let logic = newApplicationLogic(app)
  defer: logic.delete

  var engine = newQQmlApplicationEngine()
  defer: engine.delete()

  let logicVariant = newQVariant(logic)
  defer: logicVariant.delete

  engine.setRootContextProperty("logic", logicVariant)
  engine.load("main.qml")
  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
