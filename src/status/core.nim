import libstatus
import signals
import types
import chat

proc setSignalHandler(signalHandler: SignalCallback) =
  libstatus.setSignalEventCallback(signalHandler)

proc init*() =
  setSignalHandler(onSignal)

proc startMessenger*() =
  chat.startMessenger()

proc callRPC*(inputJSON: string): string =
  return $libstatus.callRPC(inputJSON)

proc callPrivateRPC*(inputJSON: string): string =
  return $libstatus.callPrivateRPC(inputJSON)
