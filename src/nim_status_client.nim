import NimQml
import chronicles
import app/chat/core as chat
import app/wallet/core as wallet
import app/node/core as node
import app/profile/core as profile
import signals/core as signals
import app/onboarding/core as onboarding
import state
import status/accounts as status_accounts
import status/core as status_core
import status/chat as status_chat
import status/types as types
import status/libstatus
import models/accounts
import state
import status/types
import eventemitter
import json_serialization

var signalsQObjPointer: pointer

logScope:
  topics = "main"

proc mainProc() =
  let nodeAccounts = Json.decode(status_accounts.initNodeAccounts(), seq[NodeAccount]) # to be used for login
  let app = newQApplication()
  let engine = newQQmlApplicationEngine()
  let signalController = signals.newController(app)
  let appEvents = createEventEmitter()

  defer: # Defer will run this just before mainProc() function ends
    app.delete()
    engine.delete()
    signalController.delete()

  # We need this global variable in order to be able to access the application
  # from the non-closure callback passed to `libstatus.setSignalEventCallback`
  signalsQObjPointer = cast[pointer](signalController.vptr)

  var appState = state.newAppState()
  debug "Application State", title=appState.title

  var wallet = wallet.newController(appEvents)
  engine.setRootContextProperty("assetsModel", wallet.variant)

  var chat = chat.newController(appEvents)
  chat.init()
  engine.setRootContextProperty("chatsModel", chat.variant)

  var node = node.newController(appEvents)
  node.init()
  engine.setRootContextProperty("nodeModel", node.variant)

  var profile = profile.newController(appEvents)
  engine.setRootContextProperty("profileModel", profile.variant)

  # var accountsModel = newAccountModel()
  appEvents.on("accountsReady") do(a: Args):
    var args = AccountArgs(a)
    status_core.startMessenger()
    wallet.init()
    profile.init(args.account) # TODO: use correct account

  # var onboarding = onboarding.newController(accountsModel)
  var onboarding = onboarding.newController(appEvents)
  onboarding.init()
  engine.setRootContextProperty("onboardingModel", onboarding.variant)

  signalController.init()
  signalController.addSubscriber(SignalType.Wallet, wallet)
  signalController.addSubscriber(SignalType.Wallet, node)
  signalController.addSubscriber(SignalType.Message, chat)
  signalController.addSubscriber(SignalType.WhisperFilterAdded, chat)
  
  engine.setRootContextProperty("signals", signalController.variant)

  appState.subscribe(proc () =
    for channel in appState.channels:
      chat.load(channel.name)
  )

  # accountsModel.appEvents.on("accountsReady") do(a: Args):
  # appEvents.on("accountsReady") do(a: Args):
  #   appState.addChannel("test")
  #   appState.addChannel("test2")
  #   appState.addChannel("status")

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
