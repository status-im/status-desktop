import libstatus
import chat
import nimcrypto

proc startMessenger*() =
  chat.startMessenger()

proc callRPC*(inputJSON: string): string =
  return $libstatus.callRPC(inputJSON)

proc callPrivateRPC*(inputJSON: string): string =
  return $libstatus.callPrivateRPC(inputJSON)

proc sendTransaction*(inputJSON: string, password: string): string =
  var hashed_password = "0x" & $keccak_256.digest(password)
  return $libstatus.sendTransaction(inputJSON, hashed_password)
