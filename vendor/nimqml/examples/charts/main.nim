import NimQml, mylistmodel

proc mainProc() =
  echo "Starting"
  var app = newQApplication()
  defer: app.delete

  var myListModel = newMyListModel();
  defer: myListModel.delete

  var engine = newQQmlApplicationEngine()
  defer: engine.delete

  var variant = newQVariant(myListModel)
  defer: variant.delete

  engine.setRootContextProperty("myListModel", variant)
  engine.load("main.qml")

  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
