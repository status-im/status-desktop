import NimQml
import eventemitter
import chronicles

import app/chat/core as chat
import app/wallet/core as wallet
import app/node/core as node
import app/profile/core as profile
import app/onboarding/core as onboarding
import app/login/core as login
import signals/core as signals

import status/libstatus/types
import status/libstatus/libstatus
import status/status as statuslib

var signalsQObjPointer: pointer

logScope:
  topics = "main"

proc mainProc() =
  let status = statuslib.newStatusInstance()
  let nodeAccounts = status.initNodeAccounts()

  let app = newQApplication()
  let engine = newQQmlApplicationEngine()
  let signalController = signals.newController(app)

  defer: # Defer will run this just before mainProc() function ends
    app.delete()
    engine.delete()
    signalController.delete()

  # We need this global variable in order to be able to access the application
  # from the non-closure callback passed to `libstatus.setSignalEventCallback`
  signalsQObjPointer = cast[pointer](signalController.vptr)

  var wallet = wallet.newController(status)
  engine.setRootContextProperty("assetsModel", wallet.variant)

  var chat = chat.newController(status)
  engine.setRootContextProperty("chatsModel", chat.variant)

  var node = node.newController(status)
  node.init()
  engine.setRootContextProperty("nodeModel", node.variant)

  var profile = profile.newController(status)
  engine.setRootContextProperty("profileModel", profile.variant)

  status.events.once("login") do(a: Args):
    var args = AccountArgs(a)
    status.startMessenger()
    chat.init()
    wallet.init()
    profile.init(args.account)

  var login = login.newController(status)
  var onboarding = onboarding.newController(status)

  # TODO: replace this with routing
  let showLogin = nodeAccounts.len > 0
  engine.setRootContextProperty("showLogin", newQVariant(showLogin))

  login.init(nodeAccounts)
  engine.setRootContextProperty("loginModel", login.variant)
  
  onboarding.init()
  engine.setRootContextProperty("onboardingModel", onboarding.variant)

  signalController.init()
  signalController.addSubscriber(SignalType.Wallet, wallet)
  signalController.addSubscriber(SignalType.Wallet, node)
  signalController.addSubscriber(SignalType.Message, chat)
  signalController.addSubscriber(SignalType.WhisperFilterAdded, chat)
  signalController.addSubscriber(SignalType.NodeLogin, login)
  signalController.addSubscriber(SignalType.NodeLogin, onboarding)
  
  engine.setRootContextProperty("signals", signalController.variant)

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
  info "Starting application..."
  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
