import NimQml
import ../../status/types as types
import tables
import json
import signalSubscriber

QtObject:
  type SignalsController* = ref object of QObject
    app: QApplication
    statusSignal: string
    signalSubscribers*: Table[SignalType, SignalSubscriber]
    variant*: QVariant

  # Constructor
  proc newController*(app: QApplication): SignalsController =
    new(result)
    result.app = app
    result.statusSignal = ""
    result.signalSubscribers = initTable[SignalType, SignalSubscriber]()
    result.setup()
    result.variant = newQVariant(result)


  proc setup(self: SignalsController) =
    self.QObject.setup

  proc init*(self: SignalsController) =
    discard

  proc delete*(self: SignalsController) =
    self.QObject.delete

  proc addSubscriber*(self: SignalsController, signalType: SignalType, subscriber: SignalSubscriber) =
    self.signalSubscribers[signalType] = subscriber

  proc processSignal(self: SignalsController) =
    let jsonSignal = (self.statusSignal).parseJson
    let signalType = $jsonSignal["type"].getStr

    # TODO: ideally the signal would receive an object 
    # formatted for easier usage so the controllers dont 
    # have to parse the signal themselves
    case signalType:
      of "messages.new":
        self.signalSubscribers[SignalType.Message].onSignal($jsonSignal)
      of "wallet":
        self.signalSubscribers[SignalType.Wallet].onSignal($jsonSignal)
      else:
        # TODO: log error?
        discard

  proc statusSignal*(self: SignalsController): string {.slot.} =
    result = self.statusSignal

  proc signalReceived*(self: SignalsController, signal: string) {.signal.}

  proc receiveSignal(self: SignalsController, signal: string) {.slot.} =
    self.statusSignal = signal
    self.processSignal()
    self.signalReceived(signal)

  QtProperty[string] statusSignal:
    read = statusSignal
    write = receiveSignal
    notify = signalReceived