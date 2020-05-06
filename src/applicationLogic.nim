import NimQml
import status

QtObject:
  type ApplicationLogic* = ref object of QObject
    app: QApplication
    callResult: string

  # Constructor
  proc newApplicationLogic*(app: QApplication): ApplicationLogic =
    new(result)
    result.app = app
    result.callResult = "Use this tool to call JSONRPC methods"
    result.setup()

    status.setupNewAccount()

  # ¯\_(ツ)_/¯ dunno what is this
  proc setup(self: ApplicationLogic) =
    self.QObject.setup

  # ¯\_(ツ)_/¯ seems to be a method for garbage collection
  proc delete*(self: ApplicationLogic) =
    self.QObject.delete

  # Read more about slots and signals here: https://doc.qt.io/qt-5/signalsandslots.html

  # This is an EventHandler
  proc onExitTriggered(self: ApplicationLogic) {.slot.} =
    self.app.quit

  proc callResult*(self: ApplicationLogic): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: ApplicationLogic, callResult: string) {.signal.}

  proc setCallResult(self: ApplicationLogic, callResult: string) {.slot.} =
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  proc `callResult=`*(self: ApplicationLogic, callResult: string) = self.setCallResult(callResult)

  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: ApplicationLogic, inputJSON: string) {.slot.} =
    self.setCallResult(status.callRPC(inputJSON))
    echo "Done!: ", self.callResult
