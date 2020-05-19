import NimQml
import app/chat/core as chat
import app/wallet/core as wallet
import app/node/core as node
import app/signals/core as signals
import state
import onboarding
import status/utils
import strformat
import strutils
import strformat
import strutils
import status/core as status
import status/chat as status_chat
import status/test as status_test
import status/types as types
import status/wallet as status_wallet
import status/libstatus
import state
import status/libstatusqml
import status/types
import eventemitter
import os

var signalsQObjPointer: pointer

proc ensureDir(dirname: string) =
  if not existsDir(dirname):
    # removeDir(dirname)
    createDir(dirname)

proc initNode(): string =
  const datadir = "./data/"
  const keystoredir = "./data/keystore/"
  const nobackupdir = "./noBackup/"

  ensureDir(datadir)
  ensureDir(keystoredir)
  ensureDir(nobackupdir)

  # 1
  result = $libstatus.initKeystore(keystoredir);

  # 2
  result = $libstatus.openAccounts(datadir);

proc mainProc() =
  discard initNode()

  let app = newQApplication()
  let engine = newQQmlApplicationEngine()
  let signalController = signals.newController(app)
  let events = createEventEmitter()

  defer: # Defer will run this just before mainProc() function ends
    app.delete()
    engine.delete()
    signalController.delete()

  # We need this global variable in order to be able to access the application
  # from the non-closure callback passed to `libstatus.setSignalEventCallback`
  signalsQObjPointer = cast[pointer](signalController.vptr)

  var appState = state.newAppState()
  echo appState.title

  # status_test.setupNewAccount()

  events.on("node:ready") do(a: Args):
    status_chat.startMessenger()

  var wallet = wallet.newController()
  events.on("node:ready") do(a: Args):
    wallet.init()
  engine.setRootContextProperty("assetsModel", wallet.variant)

  var chat = chat.newController()
  chat.init()
  engine.setRootContextProperty("chatsModel", chat.variant)

  var node = node.newController()
  node.init()
  
  engine.setRootContextProperty("nodeModel", node.variant)
  
  var onboarding = newOnboarding(events);
  defer: onboarding.delete

  let onboardingVariant = newQVariant(onboarding)
  defer: onboardingVariant.delete
  
  engine.setRootContextProperty("onboardingLogic", onboardingVariant)
  
  # TODO: figure out a way to prevent this from breaking Qt Creator
  # var initLibStatusQml = proc(): LibStatusQml =
  #   let libStatus = newLibStatusQml();
  #   return libStatus;

  # discard qmlRegisterSingletonType[LibStatusQml]("im.status.desktop.Status", 1, 0, "Status", initLibStatusQml)

  signalController.init()
  signalController.addSubscriber(SignalType.Wallet, wallet)
  signalController.addSubscriber(SignalType.Wallet, node)
  signalController.addSubscriber(SignalType.Message, chat)

  engine.setRootContextProperty("signals", signalController.variant)

  appState.subscribe(proc () =
    # chatsModel.names = @[]
    for channel in appState.channels:
      echo channel.name
      # chatsModel.addNameTolist(channel.name)
      chat.join(channel.name)
  )

  events.on("node:ready") do(a: Args):
    appState.addChannel("test")
    appState.addChannel("test2")




  
  engine.load("../ui/main.qml")

  # Please note that this must use the `cdecl` calling convention because
  # it will be passed as a regular C function to libstatus. This means that
  # we cannot capture any local variables here (we must rely on globals)
  var callback: SignalCallback = proc(p0: cstring) {.cdecl.} =
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
