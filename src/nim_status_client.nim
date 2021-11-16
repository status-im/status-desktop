import NimQml, chronicles, os, strformat, times, md5, json

import app/chat/core as chat
import app/wallet/v1/core as wallet
import app/wallet/v2/core as walletV2
import app/node/core as node
import app/utilsView/core as utilsView
import app/keycard/core as keycard
import status/types/[account]
import status_go
import status/status as statuslib
import eventemitter
import app_service/tasks/marathon/mailserver/controller as mailserver_controller
import app_service/tasks/marathon/mailserver/worker as mailserver_worker
import app_service/main
import constants

import app/global/global_singleton
import app/boot/app_controller


var signalsQObjPointer: pointer

logScope:
  topics = "main"

proc mainProc() =
  if defined(macosx) and defined(production):
    setCurrentDir(getAppDir())

  ensureDirectories(DATADIR, TMPDIR, LOGDIR)

  let fleets =
    if defined(windows) and defined(production):
      "/../resources/fleets.json"
    else:
      "/../fleets.json"

  let
    fleetConfig = readFile(joinPath(getAppDir(), fleets))
    status = statuslib.newStatusInstance(fleetConfig)
    mailserverController = mailserver_controller.newController(status)
    mailserverWorker = mailserver_worker.newMailserverWorker(cast[ByteAddress](mailserverController.vptr))

  let appService = newAppService(status, mailserverWorker)
  defer: appService.delete()

  status.initNode(STATUSGODIR, KEYSTOREDIR)

  let uiScaleFilePath = joinPath(DATADIR, "ui-scale")
  enableHDPI(uiScaleFilePath)
  initializeOpenGL()

  let app = newQGuiApplication()
  defer: app.delete()

  let appController = newAppController(appService)
  defer: appController.delete()

  let resources =
    if defined(windows) and defined(production):
      "/../resources/resources.rcc"
    else:
      "/../resources.rcc"
  QResource.registerResource(app.applicationDirPath & resources)

  var eventStr = ""
  if OPENURI.len > 0:
    eventStr = $(%* { "uri": OPENURI })
  let singleInstance = newSingleInstance($toMD5(DATADIR), eventStr)
  defer: singleInstance.delete()
  if singleInstance.secondInstance():
    info "Terminating the app as the second instance"
    quit()

  let statusAppIcon =
    if defined(production):
      if defined(macosx):
        "" # not used in macOS
      elif defined(windows):
        "/../resources/status.svg"
      else:
        "/../status.svg"
    else:
      if defined(macosx):
        "" # not used in macOS
      else:
        "/../status-dev.svg"

  if not defined(macosx):
    app.icon(app.applicationDirPath & statusAppIcon)

  let networkAccessFactory = newQNetworkAccessManagerFactory(TMPDIR & "netcache")

  singletonInstance.engine.addImportPath("qrc:/./StatusQ/src")
  singletonInstance.engine.addImportPath("qrc:/./imports")
  singletonInstance.engine.setNetworkAccessManagerFactory(networkAccessFactory)
  singletonInstance.engine.setRootContextProperty("uiScaleFilePath", newQVariant(uiScaleFilePath))

  # Register events objects
  let dockShowAppEvent = newStatusDockShowAppEventObject(singletonInstance.engine)
  defer: dockShowAppEvent.delete()
  let osThemeEvent = newStatusOSThemeEventObject(singletonInstance.engine)
  defer: osThemeEvent.delete()
  app.installEventFilter(dockShowAppEvent)
  app.installEventFilter(osThemeEvent)

  let netAccMgr = newQNetworkAccessManager(singletonInstance.engine.getNetworkAccessManager())

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


  # We need this global variable in order to be able to access the application
  # from the non-closure callback passed to `statusgo_backend.setSignalEventCallback`
  signalsQObjPointer = cast[pointer](appService.signalController.vptr)
  defer:
    signalsQObjPointer = nil

  when compiles(defaultChroniclesStream.output.writer):
    defaultChroniclesStream.output.writer =
      proc (logLevel: LogLevel, msg: LogOutputStr) {.gcsafe, raises: [Defect].} =
        try:
          if signalsQObjPointer != nil:
            signal_handler(signalsQObjPointer, ($(%* {"type": "chronicles-log", "event": msg})).cstring, "receiveSignal")
        except:
          logLoggingFailure(cstring(msg), getCurrentException())

  let logFile = fmt"app_{getTime().toUnix}.log"
  discard defaultChroniclesStream.outputs[1].open(LOGDIR & logFile, fmAppend)

  var wallet = wallet.newController(status, appService)
  defer: wallet.delete()
  singletonInstance.engine.setRootContextProperty("walletModel", wallet.variant)

  var wallet2 = walletV2.newController(status, appService)
  defer: wallet2.delete()
  singletonInstance.engine.setRootContextProperty("walletV2Model", wallet2.variant)

  var chat = chat.newController(status, appService, OPENURI)
  defer: chat.delete()
  singletonInstance.engine.setRootContextProperty("chatsModel", chat.variant)

  var node = node.newController(appService, netAccMgr)
  defer: node.delete()
  singletonInstance.engine.setRootContextProperty("nodeModel", node.variant)

  var utilsController = utilsView.newController(status, appService)
  defer: utilsController.delete()
  singletonInstance.engine.setRootContextProperty("utilsModel", utilsController.variant)

  var keycard = keycard.newController(status)
  defer: keycard.delete()

  status.events.once("loginCompleted") do(a: Args):
    var args = AccountArgs(a)

    # At the end of refactoring all this will be in the AppController class.
    status.startMessenger()
    wallet.init()
    wallet2.init()
    chat.init()
    utilsController.init()
    node.init()

    wallet.onLogin()

  # this should be the last defer in the scope
  defer:
    info "Status app is shutting down..."
    singletonInstance.delete()

  singletonInstance.engine.setRootContextProperty("keycardModel", keycard.variant)
  singletonInstance.engine.setRootContextProperty("singleInstance", newQVariant(singleInstance))

  let isExperimental = if getEnv("EXPERIMENTAL") == "1": "1" else: "0" # value explicity passed to avoid trusting input
  let experimentalFlag = newQVariant(isExperimental)
  singletonInstance.engine.setRootContextProperty("isExperimental", experimentalFlag)

  # Initialize only controllers whose init functions
  # do not need a running node
  proc initControllers() =
    keycard.init()

  initControllers()

  # Handle node.stopped signal when user has logged out
  status.events.once("nodeStopped") do(a: Args):
    # TODO: remove this once accounts are not tracked in the AccountsModel
    status.reset()

    # 1. Reset controller data
    # TODO: implement all controller resets
    # chat.reset()
    # node.reset()
    # wallet.reset()
    # wallet2.reset()
    # profile.reset()

    # 2. Re-init controllers that don't require a running node
    initControllers()

  singletonInstance.engine.setRootContextProperty("signals", appService.signalController.variant)
  singletonInstance.engine.setRootContextProperty("mailserver", mailserverController.variant)

  var prValue = newQVariant(if defined(production): true else: false)
  singletonInstance.engine.setRootContextProperty("production", prValue)

  # # We're applying default language before we load qml. Also we're aware that
  # # switch language at runtime will have some impact to cpu usage.
  # # https://doc.qt.io/archives/qtjambi-4.5.2_01/com/trolltech/qt/qtjambi-linguist-programmers.html
  # changeLanguage("en")

  appController.start()

  # Please note that this must use the `cdecl` calling convention because
  # it will be passed as a regular C function to statusgo_backend. This means that
  # we cannot capture any local variables here (we must rely on globals)
  var callback: SignalCallback = proc(p0: cstring) {.cdecl.} =
    if signalsQObjPointer != nil:
      signal_handler(signalsQObjPointer, p0, "receiveSignal")

  status_go.setSignalEventCallback(callback)

  # Qt main event loop is entered here
  # The termination of the loop will be performed when exit() or quit() is called
  info "Starting application..."
  app.exec()

when isMainModule:
  mainProc()
