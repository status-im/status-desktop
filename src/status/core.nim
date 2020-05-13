import libstatus
import signals
import types

proc setSignalHandler(signalHandler: SignalCallback) =
  libstatus.setSignalEventCallback(signalHandler)

proc init*() =
  setSignalHandler(onSignal)

proc callRPC*(inputJSON: string): string =
  return $libstatus.callRPC(inputJSON)

proc callPrivateRPC*(inputJSON: string): string =
  return $libstatus.callPrivateRPC(inputJSON)
