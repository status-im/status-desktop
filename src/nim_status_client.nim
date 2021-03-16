import NimQml, chronicles, os, strformat
import asynctools, asyncdispatch, atomics, confutils

import app/chat/core as chat
import app/wallet/core as wallet
import app/node/core as node
import app/utilsView/core as utilsView
import app/browser/core as browserView
import app/profile/core as profile
import app/onboarding/core as onboarding
import app/login/core as login
import app/provider/core as provider
import status/signals/core as signals
import status/libstatus/types
import status/libstatus/accounts/constants
import nim_status
import status/status as statuslib
import ./eventemitter

var signalsQObjPointer: pointer

logScope:
  topics = "main"

type
  CLIConfig = object
    uri* {.
      defaultValue: "",
      desc: "Protocol URL with params to open a chat or other"
      name: "url" }: string

var providerController: Web3ProviderController
var engine: QQmlApplicationEngine
var app: QApplication
var signalController: SignalsController
var loginController: LoginController
var onboardingController: OnboardingController
var walletController: WalletController
var chatController: ChatController
var profileController: ProfileController
var utilsController: UtilsController
var browserController: BrowserController
var nodeController: NodeController

var chatsQObjPointer: pointer
var ipcThread = Thread[void]()

const ipcName = "status-ipc"

var stopIPCThread: Atomic[bool]

proc killEverything() {.noconv.} =
  error "TODO: if user is logged in, logout"
  providerController.delete()
  engine.delete()
  app.delete()
  signalController.delete()
  loginController.delete()
  onboardingController.delete()
  walletController.delete()
  chatController.delete()
  profileController.delete()
  utilsController.delete()
  browserController.delete()
  nodeController.delete()

  stopIPCThread.store(true)
  try:
    let writeHandle = open(ipcName, sideWriter)
    var outBuffer = "bye"
    waitFor write(writeHandle, cast[pointer](addr outBuffer[0]), len(outBuffer))
    close(writeHandle)
    joinThread(ipcThread)
  except Exception as e:
    # Nothing to do, it probably wasn't opened
    discard

proc ipcListener() {.thread.} =
  var ipc: AsyncIpc

  while true:
    try:
      # We need to recreate the conneciton each time because on Windows, it loops infinetly otherwise
      ipc = createIpc(ipcName)
    except Exception as e:
      error "Error creating the IPC connection", msg = e.msg
      return

    # open `read` side channel to IPC object
    var readHandle = open(ipcName, sideReader)

    # reading data from IPC object
    var inBuffer = newString(145)

    var c = waitFor readInto(readHandle, cast[pointer](addr inBuffer[0]), 145)
  
    close(readHandle)
    close(ipc)

    if (stopIPCThread.load()):
      break

    inBuffer.setLen(c)

    signal_handler(chatsQObjPointer, inBuffer, "receiveUrlSignal")

proc mainProc() =
  var shouldSetupIPC = false
  
  var cfg = CliConfig.load()

  # TODO remove the windows condition once we support Mac and Linux for deep links
  if defined(windows) and cfg.uri != "":
    try:
      # Try opening the write handle to send the URL
      let writeHandle = open(ipcName, sideWriter)
      # Send URL to the main app
      var outBuffer = cfg.uri
      waitFor write(writeHandle, cast[pointer](addr outBuffer[0]), len(outBuffer))

      close(writeHandle)

      # Kill app
      quit(0)
    except Exception as e:
      # No other app started, we will create the IPC connection once we login
      discard

  let fleets =
    if defined(windows) and getEnv("NIM_STATUS_CLIENT_DEV").string == "":
      "/../resources/fleets.json"
    else:
      "/../fleets.json"

  let status = statuslib.newStatusInstance(readFile(joinPath(getAppDir(), fleets)))
  status.initNode()

  enableHDPI()
  initializeOpenGL()

  app = newQApplication("Status Desktop")
  let resources =
    if defined(windows) and getEnv("NIM_STATUS_CLIENT_DEV").string == "":
      "/../resources/resources.rcc"
    else:
      "/../resources.rcc"
  QResource.registerResource(app.applicationDirPath & resources)

  let statusAppIcon =
    if defined(macosx):
      "" # not used in macOS
    elif defined(windows) and getEnv("NIM_STATUS_CLIENT_DEV").string == "":
      "/../resources/status.svg"
    elif getEnv("NIM_STATUS_CLIENT_DEV").string != "":
      "/../status-dev.svg"
    else:
      "/../status.svg"
  if not defined(macosx):
    app.icon(app.applicationDirPath & statusAppIcon)

  var i18nPath = ""
  if (getEnv("NIM_STATUS_CLIENT_DEV").string != ""):
    i18nPath = joinPath(getAppDir(), "../ui/i18n")
  elif (defined(windows)):
    i18nPath = joinPath(getAppDir(), "../resources/i18n")
  elif (defined(macosx)):
    i18nPath = joinPath(getAppDir(), "../i18n")
  elif (defined(linux)):
    i18nPath = joinPath(getAppDir(), "../i18n")

  let networkAccessFactory = newQNetworkAccessManagerFactory(TMPDIR & "netcache")

  engine = newQQmlApplicationEngine()
  engine.setNetworkAccessManagerFactory(networkAccessFactory)

  let netAccMgr = newQNetworkAccessManager(engine.getNetworkAccessManager())

  status.events.on("network:connected") do(e: Args):
    # This is a workaround for Qt bug https://bugreports.qt.io/browse/QTBUG-55180
    # that was apparently reintroduced in 5.14.1 Unfortunately, the only workaround
    # that could be found uses obsolete properties and methods
    # (https://doc.qt.io/qt-5/qnetworkaccessmanager-obsolete.html), so this will
    # need to be something we keep in mind when upgrading to Qt 6.
    # The workaround is to manually set the NetworkAccessible property of the
    # QNetworkAccessManager once peers have dropped (network connection is lost).
    netAccMgr.clearConnectionCache()
    netAccMgr.setNetworkAccessible(NetworkAccessibility.Accessible)

  signalController = signals.newController(status)

  # We need this global variable in order to be able to access the application
  # from the non-closure callback passed to `libstatus.setSignalEventCallback`
  signalsQObjPointer = cast[pointer](signalController.vptr)

  walletController = wallet.newController(status)
  engine.setRootContextProperty("walletModel", walletController.variant)

  chatController = chat.newController(status)
  engine.setRootContextProperty("chatsModel", chatController.variant)
  chatsQObjPointer = cast[pointer](chatController.view.vptr)

  nodeController = node.newController(status, netAccMgr)
  engine.setRootContextProperty("nodeModel", nodeController.variant)

  utilsController = utilsView.newController(status)
  engine.setRootContextProperty("utilsModel", utilsController.variant)

  browserController = browserView.newController(status)
  engine.setRootContextProperty("browserModel", browserController.variant)

  proc changeLanguage(locale: string) =
    engine.setTranslationPackage(joinPath(i18nPath, fmt"qml_{locale}.qm"))

  profileController = profile.newController(status, changeLanguage)
  engine.setRootContextProperty("profileModel", profileController.variant)

  providerController = provider.newController(status)
  engine.setRootContextProperty("web3Provider", providerController.variant)

  loginController = login.newController(status)
  onboardingController = onboarding.newController(status)

  status.events.once("login") do(a: Args):
    var args = AccountArgs(a)
    # Delete login and onboarding from memory to remove any mnemonic that would have been saved in the accounts list
    loginController.delete()
    onboardingController.delete()

    status.startMessenger()
    profileController.init(args.account)
    walletController.init()
    providerController.init()
    chatController.init(cfg.uri)
    utilsController.init()
    browserController.init()

    walletController.checkPendingTransactions()
    walletController.start()

    # TODO remove this condition once we support Mac and Linux for deep links
    if defined(windows):
      # Start IPC
      ipcThread.createThread(ipcListener)

  engine.setRootContextProperty("loginModel", loginController.variant)
  engine.setRootContextProperty("onboardingModel", onboardingController.variant)

  let isExperimental = if getEnv("EXPERIMENTAL") == "1": "1" else: "0" # value explicity passed to avoid trusting input
  let experimentalFlag = newQVariant(isExperimental)
  engine.setRootContextProperty("isExperimental", experimentalFlag)


  defer:
    killEverything()

  setControlCHook(killEverything)

  # Initialize only controllers whose init functions
  # do not need a running node
  proc initControllers() =
    nodeController.init()
    loginController.init()
    onboardingController.init()

  initControllers()

  # Handle node.stopped signal when user has logged out
  status.events.once("nodeStopped") do(a: Args):
    # TODO: remove this once accounts are not tracked in the AccountsModel
    status.reset()

    # 1. Reset controller data
    loginController.reset()
    onboardingController.reset()
    # TODO: implement all controller resets
    # chatController.reset()
    # nodeController.reset()
    # walletController.reset()
    # profileController.reset()

    # 2. Re-init controllers that don't require a running node
    initControllers()

  engine.setRootContextProperty("signals", signalController.variant)

  engine.load(newQUrl("qrc:///main.qml"))

  # Please note that this must use the `cdecl` calling convention because
  # it will be passed as a regular C function to libstatus. This means that
  # we cannot capture any local variables here (we must rely on globals)
  var callback: SignalCallback = proc(p0: cstring) {.cdecl.} =
    setupForeignThreadGc()
    signal_handler(signalsQObjPointer, p0, "receiveSignal")
    tearDownForeignThreadGc()

  nim_status.setSignalEventCallback(callback)

  # Qt main event loop is entered here
  # The termination of the loop will be performed when exit() or quit() is called
  info "Starting application..."
  app.exec()

when isMainModule:
  mainProc()
  GC_fullcollect()
