import NimQml, chronicles, os, strformat, strutils, times, md5, json

import status_go
import keycard_go
import app/core/main
import constants as main_constants

import app/global/global_singleton
import app/boot/app_controller

when defined(macosx) and defined(arm64):
  import posix

logScope:
  topics = "status-app"

var signalsManagerQObjPointer: pointer
var keycardServiceQObjPointer: pointer

proc isExperimental(): string =
  result = if getEnv("EXPERIMENTAL") == "1": "1" else: "0" # value explicity passed to avoid trusting input

proc determineResourcePath(): string =
  result = if defined(windows) and defined(production): "/../resources/resources.rcc" else: "/../resources.rcc"

proc determineFleetsPath(): string =
  result = if defined(windows) and defined(production): "/../resources/fleets.json" else: "/../fleets.json"

proc determineOpenUri(): string =
  if OPENURI.len > 0:
    result = OPENURI

proc determineStatusAppIconPath(): string =
  if defined(production):
    if main_constants.IS_MACOS:
      return "" # not used in macOS
    elif defined(windows):
      return "/../resources/status.svg"
    else:
      return "/../status.svg"
  else:
    if main_constants.IS_MACOS:
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
            signal_handler(signalsManagerQObjPointer, ($(%* {"type": "chronicles-log", "event": msg})).cstring, "receiveChroniclesLogEvent")
        except:
          logLoggingFailure(cstring(msg), getCurrentException())

  let defaultLogLvl = if defined(production): chronicles.LogLevel.INFO else: chronicles.LogLevel.DEBUG
  # default log level can be overriden by LOG_LEVEL env parameter
  let logLvl = try: parseEnum[chronicles.LogLevel](main_constants.LOG_LEVEL)
               except: defaultLogLvl

  setLogLevel(logLvl)

  let formattedDate = now().format("yyyyMMdd'_'HHmmss")
  let logFile = fmt"app_{formattedDate}.log"
  discard defaultChroniclesStream.outputs[1].open(LOGDIR & logFile, fmAppend)

proc setupRemoteSignalsHandling() =
  # Please note that this must use the `cdecl` calling convention because
  # it will be passed as a regular C function to statusgo_backend. This means that
  # we cannot capture any local variables here (we must rely on globals)
  var callbackStatusGo: status_go.SignalCallback = proc(p0: cstring) {.cdecl.} =
    if signalsManagerQObjPointer != nil:
      signal_handler(signalsManagerQObjPointer, p0, "receiveSignal")
  status_go.setSignalEventCallback(callbackStatusGo)

  var callbackKeycardGo: keycard_go.KeycardSignalCallback = proc(p0: cstring) {.cdecl.} =
    if keycardServiceQObjPointer != nil:
      signal_handler(keycardServiceQObjPointer, p0, "receiveKeycardSignal")
  keycard_go.setSignalEventCallback(callbackKeycardGo)

proc ensureDirectories*(dataDir, tmpDir, logDir: string) =
  createDir(dataDir)
  createDir(tmpDir)
  createDir(logDir)

proc mainProc() =

  when defined(macosx) and defined(arm64):
    echo "Experimental support for Apple Silicon"
    var signalStack: cstring = cast[cstring](allocShared(SIGSTKSZ))
    var ss: ptr Stack = cast[ptr Stack](allocShared0(sizeof(Stack)))
    var ss2: ptr Stack = nil
    ss.ss_sp = signalStack
    ss.ss_flags = 0
    ss.ss_size = SIGSTKSZ
    if sigaltstack(ss[], ss2[]) < 0:
        echo("sigaltstack error!")
        quit()

    var sa: ptr Sigaction = cast[ptr Sigaction](allocShared0(sizeof(Sigaction)))
    var sa2: Sigaction

    sa.sa_handler = SIG_DFL
    sa.sa_flags = SA_ONSTACK

    if sigaction(SIGURG, sa[], addr sa2) < 0:
        echo("sigaction error!")
        quit()

  if main_constants.IS_MACOS and defined(production):
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
  tryEnableThreadedRenderer()
  initializeOpenGL()

  let imageCert = imageServerTLSCert()
  installSelfSignedCertificate(imageCert)

  let app = newQGuiApplication()

  # Required by the WalletConnectSDK view right after creating the QGuiApplication instance
  initializeWebView()

  let singleInstance = newSingleInstance($toMD5(DATADIR), openUri)
  let urlSchemeEvent = newStatusUrlSchemeEventObject()
  # init url manager before app controller
  statusFoundation.initUrlSchemeManager(urlSchemeEvent, singleInstance, openUri)

  let appController = newAppController(statusFoundation)
  let networkAccessFactory = newQNetworkAccessManagerFactory(TMPDIR & "netcache")

  let isProductionQVariant = newQVariant(if defined(production): true else: false)
  let isExperimentalQVariant = newQVariant(isExperimental)
  let signalsManagerQVariant = newQVariant(statusFoundation.signalsManager)

  QResource.registerResource(app.applicationDirPath & resourcesPath)
  # Register events objects
  let osThemeEvent = newStatusOSThemeEventObject(singletonInstance.engine)

  if not main_constants.IS_MACOS:
    app.icon(app.applicationDirPath & statusAppIconPath)

  prepareLogging()

  singletonInstance.engine.addImportPath("qrc:/")
  singletonInstance.engine.addImportPath("qrc:/./imports")
  singletonInstance.engine.addImportPath("qrc:/./app");
  singletonInstance.engine.setNetworkAccessManagerFactory(networkAccessFactory)
  singletonInstance.engine.setRootContextProperty("uiScaleFilePath", newQVariant(uiScaleFilePath))
  singletonInstance.engine.setRootContextProperty("singleInstance", newQVariant(singleInstance))
  singletonInstance.engine.setRootContextProperty("isExperimental", isExperimentalQVariant)
  singletonInstance.engine.setRootContextProperty("signals", signalsManagerQVariant)
  singletonInstance.engine.setRootContextProperty("production", isProductionQVariant)

  app.installEventFilter(osThemeEvent)
  app.installEventFilter(urlSchemeEvent)

  defer:
    info "shutting down..."
    signalsManagerQObjPointer = nil
    keycardServiceQObjPointer = nil
    isProductionQVariant.delete()
    isExperimentalQVariant.delete()
    signalsManagerQVariant.delete()
    networkAccessFactory.delete()
    osThemeEvent.delete()
    appController.delete()
    statusFoundation.delete()
    singleInstance.delete()
    app.delete()

  # Checks below must be always after "defer", in case anything fails destructors will freed a memory.
  if singleInstance.secondInstance():
    info "Terminating the app as the second instance"
    quit()

  # We need these global variables in order to be able to access the application
  # from the non-closure callback passed to `statusgo_backend.setSignalEventCallback`
  signalsManagerQObjPointer = cast[pointer](statusFoundation.signalsManager.vptr)
  keycardServiceQObjPointer = cast[pointer](appController.keycardService.vptr)
  setupRemoteSignalsHandling()

  info fmt("Version: {APP_VERSION}")
  info fmt("Commit: {GIT_COMMIT}")
  info "Current date:", currentDateTime=now()

  info "starting application controller..."
  appController.start()

  info "starting application..."
  app.exec()

when isMainModule:
  mainProc()
