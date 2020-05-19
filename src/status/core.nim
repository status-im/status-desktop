import libstatus
import chat

proc startMessenger*() =
  chat.startMessenger()

proc callRPC*(inputJSON: string): string =
  return $libstatus.callRPC(inputJSON)

proc callPrivateRPC*(inputJSON: string): string =
  return $libstatus.callPrivateRPC(inputJSON)

proc sendTransaction*(inputJSON: string, password: string): string =
  return $libstatus.sendTransaction(inputJSON, password)
