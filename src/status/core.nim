import libstatus
import signals
import types
import chat
import "../state"

proc setSignalHandler(signalHandler: SignalCallback) =
  libstatus.setSignalEventCallback(signalHandler)

proc init*(state: AppState) =
  setSignalHandler(onSignal(state))

proc startMessenger*() =
  chat.startMessenger()

proc callRPC*(inputJSON: string): string =
  return $libstatus.callRPC(inputJSON)

proc callPrivateRPC*(inputJSON: string): string =
  return $libstatus.callPrivateRPC(inputJSON)
