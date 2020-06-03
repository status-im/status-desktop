import json
import libstatus
import nimcrypto
import utils
import chronicles

logScope:
  topics = "rpc"

proc callRPC*(inputJSON: string): string =
  return $libstatus.callRPC(inputJSON)

proc callPrivateRPCRaw*(inputJSON: string): string =
  return $libstatus.callPrivateRPC(inputJSON)

proc callPrivateRPC*(methodName: string, payload = %* []): string =
  try:
    let inputJSON = %* {
      "jsonrpc": "2.0",
      "method": methodName,
      "params": %payload
    }
    debug "calling json", request = $inputJSON
    let response = libstatus.callPrivateRPC($inputJSON)
    result = $response
    if parseJSON(result).hasKey("error"):
      error "rpc response error", result = result
  except:
    error "error doing rpc request", methodName = methodName

proc sendTransaction*(inputJSON: string, password: string): string =
  var hashed_password = "0x" & $keccak_256.digest(password)
  return $libstatus.sendTransaction(inputJSON, hashed_password)

proc startMessenger*() =
  discard callPrivateRPC("startMessenger".prefix)

proc addPeer*(peer: string) = 
  discard callPrivateRPC("admin_addPeer", %* [peer])

proc removePeer*(peer: string) = 
  discard callPrivateRPC("admin_removePeer", %* [peer])

proc markTrustedPeer*(peer: string) = 
  discard callPrivateRPC("markTrustedPeer".prefix(false), %* [peer])
