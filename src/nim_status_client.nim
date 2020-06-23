import NimQml, eventemitter, chronicles

import app/chat/core as chat
import app/wallet/core as wallet
import app/node/core as node
import app/profile/core as profile
import app/onboarding/core as onboarding
import app/login/core as login
import signals/core as signals

import status/libstatus/[types, libstatus]
import status/status as statuslib

var signalsQObjPointer: pointer

logScope:
  topics = "main"

proc mainProc() =
  let status = statuslib.newStatusInstance()
  status.initNode()

  enableHDPI()

  let app = newQApplication()
  let engine = newQQmlApplicationEngine()
  let signalController = signals.newController(app)

  # We need this global variable in order to be able to access the application
  # from the non-closure callback passed to `libstatus.setSignalEventCallback`
  signalsQObjPointer = cast[pointer](signalController.vptr)

  var wallet = wallet.newController(status)
  engine.setRootContextProperty("walletModel", wallet.variant)

  var chat = chat.newController(status)
  engine.setRootContextProperty("chatsModel", chat.variant)

  var node = node.newController(status)
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

  engine.setRootContextProperty("loginModel", login.variant)
  engine.setRootContextProperty("onboardingModel", onboarding.variant)

  defer:
    error "TODO: if user is logged in, logout"
    engine.delete()
    app.delete()
    signalController.delete()
    login.delete()
    onboarding.delete()
    wallet.delete()
    chat.delete()
    profile.delete()


  # Initialize only controllers whose init functions
  # do not need a running node
  proc initControllers() =
    node.init()
    login.init()
    onboarding.init()
  
  initControllers()

  # Handle node.stopped signal when user has logged out
  status.events.once("nodeStopped") do(a: Args):
    # TODO: remove this once accounts are not tracked in the AccountsModel
    status.reset()

    # 1. Reset controller data
    login.reset()
    onboarding.reset()
    # TODO: implement all controller resets
    # chat.reset()
    # node.reset()
    # wallet.reset()
    # profile.reset()
    
    # 2. Re-init controllers that don't require a running node
    initControllers()


  signalController.init()
  signalController.addSubscriber(SignalType.Wallet, wallet)
  signalController.addSubscriber(SignalType.Wallet, node)
  signalController.addSubscriber(SignalType.Message, chat)
  signalController.addSubscriber(SignalType.Message, profile)
  signalController.addSubscriber(SignalType.DiscoverySummary, chat)
  signalController.addSubscriber(SignalType.NodeLogin, login)
  signalController.addSubscriber(SignalType.NodeLogin, onboarding)
  signalController.addSubscriber(SignalType.NodeStopped, login)
  signalController.addSubscriber(SignalType.NodeStarted, login)
  signalController.addSubscriber(SignalType.NodeReady, login)

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
