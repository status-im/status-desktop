import NimQml, chronicles, os, strformat, strutils, times, md5, json

import status_go
import app/core/main
import constants

import app/global/global_singleton
import app/boot/app_controller

logScope:
  topics = "status-app"

var signalsManagerQObjPointer: pointer

proc isExperimental(): string =
  result = if getEnv("EXPERIMENTAL") == "1": "1" else: "0" # value explicity passed to avoid trusting input

proc determineResourcePath(): string =
  result = if defined(windows) and defined(production): "/../resources/resources.rcc" else: "/../resources.rcc"

proc determineFleetsPath(): string =
  result = if defined(windows) and defined(production): "/../resources/fleets.json" else: "/../fleets.json"

proc determineOpenUri(): string =
  if OPENURI.len > 0:
    result = $(%* { "uri": OPENURI })

proc determineStatusAppIconPath(): string =
  if defined(production):
    if defined(macosx):
      return "" # not used in macOS
    elif defined(windows):
      return "/../resources/status.svg"
    else:
      return "/../status.svg"
  else:
    if defined(macosx):
      return "" # not used in macOS
    else:
      return "/../status-dev.svg"

proc prepareLogging() =
  # Outputs logs in the node tab
  when compiles(defaultChroniclesStream.output.writer):
    defaultChroniclesStream.output.writer =
      proc (logLevel: LogLevel, msg: LogOutputStr) {.gcsafe, raises: [Defect].} =
        try:
          if signalsManagerQObjPointer != nil:
            signal_handler(signalsManagerQObjPointer, ($(%* {"type": "chronicles-log", "event": msg})).cstring, "receiveSignal")
        except:
          logLoggingFailure(cstring(msg), getCurrentException())

  # do not create log file
  when not defined(production):
    # log level can be overriden by LOG_LEVEL env parameter
    let logLvl = try: parseEnum[LogLevel](getEnv("LOG_LEVEL"))
                      except: NONE

    setLogLevel(logLvl)

    let formattedDate = now().format("yyyyMMdd'_'HHmmss")
    let logFile = fmt"app_{formattedDate}.log"
    discard defaultChroniclesStream.outputs[1].open(LOGDIR & logFile, fmAppend)

proc setupRemoteSignalsHandling() =
  # Please note that this must use the `cdecl` calling convention because
  # it will be passed as a regular C function to statusgo_backend. This means that
  # we cannot capture any local variables here (we must rely on globals)
  var callback: SignalCallback = proc(p0: cstring) {.cdecl.} =
    if signalsManagerQObjPointer != nil:
      signal_handler(signalsManagerQObjPointer, p0, "receiveSignal")

  status_go.setSignalEventCallback(callback)

proc mainProc() =
  if defined(macosx) and defined(production):
    setCurrentDir(getAppDir())

  ensureDirectories(DATADIR, TMPDIR, LOGDIR)

  let isExperimental = isExperimental()
  let resourcesPath = determineResourcePath()
  let fleetsPath = determineFleetsPath()
  let openUri = determineOpenUri()
  let statusAppIconPath = determineStatusAppIconPath()

  let fleetConfig = readFile(joinPath(getAppDir(), fleetsPath))
  let statusFoundation = newStatusFoundation(fleetConfig)
  let uiScaleFilePath = joinPath(DATADIR, "ui-scale")
  enableHDPI(uiScaleFilePath)
  initializeOpenGL()

  let imageCert = imageServerTLSCert()
  installSelfSignedCertificate(imageCert)

  let app = newQGuiApplication()
  os.putEnv("QT_QUICK_CONTROLS_HOVER_ENABLED", "1")
  let appController = newAppController(statusFoundation)
  let singleInstance = newSingleInstance($toMD5(DATADIR), openUri)
  let networkAccessFactory = newQNetworkAccessManagerFactory(TMPDIR & "netcache")

  let isProductionQVariant = newQVariant(if defined(production): true else: false)
  let isExperimentalQVariant = newQVariant(isExperimental)
  let signalsManagerQVariant = newQVariant(statusFoundation.signalsManager)

  QResource.registerResource(app.applicationDirPath & resourcesPath)
  # Register events objects
  let dockShowAppEvent = newStatusDockShowAppEventObject(singletonInstance.engine)
  let osThemeEvent = newStatusOSThemeEventObject(singletonInstance.engine)
  let urlSchemeEvent = newStatusUrlSchemeEventObject()

  statusFoundation.initUrlSchemeManager(urlSchemeEvent)

  if not defined(macosx):
    app.icon(app.applicationDirPath & statusAppIconPath)

  prepareLogging()

  singletonInstance.engine.addImportPath("qrc:/./StatusQ/src")
  singletonInstance.engine.addImportPath("qrc:/./imports")
  singletonInstance.engine.addImportPath("qrc:/./app");
  singletonInstance.engine.setNetworkAccessManagerFactory(networkAccessFactory)
  singletonInstance.engine.setRootContextProperty("uiScaleFilePath", newQVariant(uiScaleFilePath))
  singletonInstance.engine.setRootContextProperty("singleInstance", newQVariant(singleInstance))
  singletonInstance.engine.setRootContextProperty("isExperimental", isExperimentalQVariant)
  singletonInstance.engine.setRootContextProperty("signals", signalsManagerQVariant)
  singletonInstance.engine.setRootContextProperty("production", isProductionQVariant)

  app.installEventFilter(dockShowAppEvent)
  app.installEventFilter(osThemeEvent)
  app.installEventFilter(urlSchemeEvent)

  defer:
    info "shutting down..."
    signalsManagerQObjPointer = nil
    isProductionQVariant.delete()
    isExperimentalQVariant.delete()
    signalsManagerQVariant.delete()
    networkAccessFactory.delete()
    dockShowAppEvent.delete()
    osThemeEvent.delete()
    statusFoundation.delete()
    appController.delete()
    singleInstance.delete()
    app.delete()

  # Checks below must be always after "defer", in case anything fails destructors will freed a memory.
  if singleInstance.secondInstance():
    info "Terminating the app as the second instance"
    quit()

  info fmt("Version: {DESKTOP_VERSION}")
  info fmt("Commit: {GIT_COMMIT}")
  info "Current date:", currentDateTime=now()

  info "starting application controller..."
  appController.start()

  # We need this global variable in order to be able to access the application
  # from the non-closure callback passed to `statusgo_backend.setSignalEventCallback`
  signalsManagerQObjPointer = cast[pointer](statusFoundation.signalsManager.vptr)
  setupRemoteSignalsHandling()

  info "starting application..."
  app.exec()

when isMainModule:
  mainProc()
