import NimQml
import status
import libstatus
import json
import state

var signalHandler: SignalCallback = proc(p0: cstring): void =
  setupForeignThreadGc()

  var jsonSignal = ($p0).parseJson
  if $jsonSignal["type"].getStr == "messages.new":
    echo $p0

  tearDownForeignThreadGc()


# Probably all QT classes will look like this:
QtObject:
  type ApplicationLogic* = ref object of QObject
    app: QApplication
    callResult: string
    accountResult: string

  # Constructor
  proc newApplicationLogic*(app: QApplication): ApplicationLogic =
    new(result)
    result.app = app
    result.callResult = "Use this tool to call JSONRPC methods"
    result.setup()

    status.setSignalHandler(signalHandler)

    status.setupNewAccount()
    discard status.addPeer("enode://2c8de3cbb27a3d30cbb5b3e003bc722b126f5aef82e2052aaef032ca94e0c7ad219e533ba88c70585ebd802de206693255335b100307645ab5170e88620d2a81@47.244.221.14:443")
    echo status.callPrivateRPC("{\"jsonrpc\":\"2.0\", \"method\":\"wakuext_requestMessages\", \"params\":[{\"topics\": [\"0x7998f3c8\"]}], \"id\": 1}")

    result.accountResult = status.queryAccounts()
    status.subscribeToTest()    

    var appState = state.newAppState()
    echo appState.title
    appState.subscribe(proc () =
      echo "1nd subscriber got a new update!"
    )

    appState.addChannel("test")

    appState.subscribe(proc () =
      echo "2nd subscriber got a new update!"
    )

    appState.addChannel("test2")
    for channel in appState.channels:
      echo channel.name

  # ¯\_(ツ)_/¯ dunno what is this
  proc setup(self: ApplicationLogic) =
    # discard status.onMessage(self.onMessage)
    self.QObject.setup

  # ¯\_(ツ)_/¯ seems to be a method for garbage collection
  proc delete*(self: ApplicationLogic) =
    self.QObject.delete

  # Read more about slots and signals here: https://doc.qt.io/qt-5/signalsandslots.html

  # This is an EventHandler
  proc onExitTriggered(self: ApplicationLogic) {.slot.} =
    self.app.quit


  # Accesors
  proc callResult*(self: ApplicationLogic): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: ApplicationLogic, callResult: string) {.signal.}

  proc setCallResult(self: ApplicationLogic, callResult: string) {.slot.} =
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  proc `callResult=`*(self: ApplicationLogic, callResult: string) = self.setCallResult(callResult)

  # Binding between a QML variable and accesors is done here
  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: ApplicationLogic, inputJSON: string) {.slot.} =
    self.setCallResult(status.callPrivateRPC(inputJSON))
    echo "Done!: ", self.callResult

  # proc onMessage*(self: ApplicationLogic, message: string) {.slot.} =
  #   self.setCallResult(message)
  #   echo "Received message: ", message

  proc accountResultChanged*(self: ApplicationLogic, callResult: string) {.signal.}

  proc accountResult*(self: ApplicationLogic): string {.slot.} =
    result = self.accountResult

  proc setAccountResult(self: ApplicationLogic, accountResult: string) {.slot.} =
    if self.accountResult == accountResult: return
    self.accountResult = accountResult
    self.accountResultChanged(accountResult)

  QtProperty[string] accountResult:
    read = accountResult
    write = setAccountResult
    notify = callResultChanged

  # This class has the metaObject property available which lets 
  # access all the QProperties which are stored as QVariants