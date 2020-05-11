import NimQml
import applicationLogic
import chats
import state
import status
import libstatus
import json

var signalHandler: SignalCallback = proc(p0: cstring): void =
  setupForeignThreadGc()

  var jsonSignal = ($p0).parseJson
  if $jsonSignal["type"].getStr == "messages.new":
    echo $p0

  tearDownForeignThreadGc()

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


  status.setSignalHandler(signalHandler)

  status.setupNewAccount()
  discard status.addPeer("enode://2c8de3cbb27a3d30cbb5b3e003bc722b126f5aef82e2052aaef032ca94e0c7ad219e533ba88c70585ebd802de206693255335b100307645ab5170e88620d2a81@47.244.221.14:443")
  echo status.callPrivateRPC("{\"jsonrpc\":\"2.0\", \"method\":\"wakuext_requestMessages\", \"params\":[{\"topics\": [\"0x7998f3c8\"]}], \"id\": 1}")

  # result.accountResult = status.queryAccounts()
  status.subscribeToTest()

  let logic = newApplicationLogic(app, status.callPrivateRPC)
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
