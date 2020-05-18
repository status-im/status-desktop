import NimQml
import app/chat/core as chat
import app/wallet/core as wallet
import app/node/core as node
import app/signals/core as signals
import state
import strformat
import strutils
import status/core as status
import status/chat as status_chat
import status/test as status_test
import status/types as types
import status/wallet as status_wallet
import status/libstatus
import state



# From QT docs:
# For any GUI application using Qt, there is precisely one QApplication object,
# no matter whether the application has 0, 1, 2 or more windows at any given time.
# For non-QWidget based Qt applications, use QGuiApplication instead, as it does
# not depend on the QtWidgets library. Use QCoreApplication for non GUI apps

# Global variables required due to issue described on line 75
var app = newQApplication()

var signalController = signals.newController(app)
var signalsQObjPointer = cast[pointer](signalController.vptr)

proc mainProc() =
  defer: app.delete() # Defer will run this just before mainProc() function ends

  var engine = newQQmlApplicationEngine()
  defer: engine.delete()

  var appState = state.newAppState()
  echo appState.title

  # TODO: @RR: commented until I'm able to fix the global variable issue described below
  #status.init(appState)

  status_test.setupNewAccount()

  status_chat.startMessenger()

  var wallet = wallet.newController()
  wallet.init()
  engine.setRootContextProperty("assetsModel", wallet.variant)

  var chat = chat.newController()
  chat.init()
  engine.setRootContextProperty("chatsModel", chat.variant)

  var node = node.newController()
  node.init()
  engine.setRootContextProperty("nodeModel", node.variant)


  signalController.init()
  signalController.addSubscriber(SignalType.Wallet, wallet)
  signalController.addSubscriber(SignalType.Message, chat)
  
  engine.setRootContextProperty("signals", signalController.variant)

  appState.subscribe(proc () =
    # chatsModel.names = @[]
    for channel in appState.channels:
      echo channel.name
      # chatsModel.addNameTolist(channel.name)
      chat.join(channel.name)
  )

  appState.addChannel("test")
  appState.addChannel("test2")
  
  engine.load("../ui/main.qml")
  

  # In order for status-go to be able to trigger QT events
  # the signal handler must work with the same pointers
  # and use the cdecl pragma. If I remove this pragma and use
  # a normal closure and the `logic` object, the pointer to
  # this `logic` changes each time the callback is executed
  # I also had to use a global variable, because Nim complains
  # "illegal capture 'logicQObjPointer' because ':anonymous' 
  # has the calling convention: <cdecl>"
  # TODO: ask nimbus team how to work with raw pointers to avoid
  #       using global variables
  var callback:SignalCallback = proc(p0: cstring) {.cdecl.} =
    setupForeignThreadGc()
    signal_handler(signalsQObjPointer, p0, "receiveSignal")
    tearDownForeignThreadGc()

  libstatus.setSignalEventCallback(callback)
  

  # Qt main event loop is entered here
  # The termination of the loop will be performed when exit() or quit() is called
  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
