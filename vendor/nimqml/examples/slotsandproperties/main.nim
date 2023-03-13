import NimQml
import contact

proc mainProc() =
  var app = newQApplication()
  defer: app.delete()

  var contact = newContact()
  defer: contact.delete()

  var engine = newQQmlApplicationEngine()
  defer: engine.delete()

  var variant = newQVariant(contact)
  defer: variant.delete()

  engine.setRootContextProperty("contact", variant)
  engine.load("main.qml")
  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
