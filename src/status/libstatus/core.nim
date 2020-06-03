import json
import libstatus
import nimcrypto
import utils

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
    result = $libstatus.callPrivateRPC($inputJSON)
  except:
    echo "error doing rpc request"
    echo methodName

proc sendTransaction*(inputJSON: string, password: string): string =
  var hashed_password = "0x" & $keccak_256.digest(password)
  return $libstatus.sendTransaction(inputJSON, hashed_password)

proc startMessenger*() =
  discard callPrivateRPC("startMessenger".prefix)

proc addPeer*(peer: string) = 
  discard callPrivateRPC("admin_addPeer", %* [peer])

proc removePeer*(peer: string) = 
  echo "TODO: removePeer"

proc markTrustedPeer*(peer: string) = 
  discard callPrivateRPC("markTrustedPeer".prefix(false), %* [peer])
