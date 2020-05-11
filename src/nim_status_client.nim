import NimQml
import applicationLogic
import chats
import state

proc mainProc() =

  # From QT docs:
  # For any GUI application using Qt, there is precisely one QApplication object, 
  # no matter whether the application has 0, 1, 2 or more windows at any given time. 
  # For non-QWidget based Qt applications, use QGuiApplication instead, as it does 
  # not depend on the QtWidgets library. Use QCoreApplication for non GUI apps
  var app = newQApplication()
  defer: app.delete()       # Defer will run this just before mainProc() function ends

  var chatsModel = newChatsModel();
  defer: chatsModel.delete

  var engine = newQQmlApplicationEngine()
  defer: engine.delete()


  let logic = newApplicationLogic(app)
  defer: logic.delete
  
  let logicVariant = newQVariant(logic)
  defer: logicVariant.delete

  let chatsVariant = newQVariant(chatsModel)
  defer: chatsVariant.delete

  var appState = state.newAppState()
  echo appState.title

  appState.subscribe(proc () =
    chatsModel.names = @[]
    for channel in appState.channels:
      echo channel.name
      chatsModel.addNameTolist(channel.name)
  )

  appState.addChannel("test")
  appState.addChannel("test2")

  engine.setRootContextProperty("logic", logicVariant)
  engine.setRootContextProperty("chatsModel", chatsVariant)
  engine.load("main.qml")
  
  # Qt main event loop is entered here
  # The termination of the loop will be performed when exit() or quit() is called
  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
