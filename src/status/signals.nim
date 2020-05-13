import types
import json
import "../state" as state

proc onSignal*(state: AppState): SignalCallback =
  result = proc(p0: cstring): void =
    setupForeignThreadGc()
    let jsonSignal = ($p0).parseJson
    let signalType = $jsonSignal["type"].getStr

    case signalType:
      of "messages.new":
        state.nextSignal(SignalType.Message, $jsonSignal)
      else:
        state.nextSignal(SignalType.Unknown, $jsonSignal)


    tearDownForeignThreadGc()

