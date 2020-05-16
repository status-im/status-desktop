import libstatus
import chat

# TODO: move signal handler from nim_status_client.nim
# proc init*(state: AppState) =
#  setSignalHandler(onSignal(state))

proc startMessenger*() =
  chat.startMessenger()

proc callRPC*(inputJSON: string): string =
  return $libstatus.callRPC(inputJSON)

proc callPrivateRPC*(inputJSON: string): string =
  return $libstatus.callPrivateRPC(inputJSON)
