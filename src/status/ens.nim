import strutils
import profile/profile
import nimcrypto
import json
import strformat
import libstatus/core
import stew/byteutils
import unicode
import algorithm

const domain* = ".stateofus.eth"

proc userName*(ensName: string, removeSuffix: bool = false): string =
  if ensName != "" and ensName.endsWith(domain):
    if removeSuffix: 
      result = ensName.split(".")[0]
    else:
      result = ensName
  else:
    result = ensName

proc addDomain*(username: string): string =
  if username.endsWith(".eth"):
    return username
  else:
    return username & domain

proc userNameOrAlias*(contact: Profile): string =
  if(contact.ensName != "" and contact.ensVerified):
    result = "@" & userName(contact.ensName, true)
  else:
    result = contact.alias

proc namehash*(ensName:string): string =
  let name = ensName.toLower()
  var node:array[32, byte]

  node.fill(0)
  var parts = name.split(".")
  for i in countdown(parts.len - 1,0):
    let elem = keccak_256.digest(parts[i]).data
    var concatArrays: array[64, byte]
    concatArrays[0..31] = node
    concatArrays[32..63] = elem
    node = keccak_256.digest(concatArrays).data
  
  result = "0x" & node.toHex()

const registry = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
const resolver_signature = "0x0178b8bf"
proc resolver*(usernameHash: string): string =
  let payload = %* [{
    "to": registry,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{resolver_signature}{userNameHash}"
  }, "latest"]
  let response = callPrivateRPC("eth_call", payload)
  # TODO: error handling
  var resolverAddr = response.parseJson["result"].getStr
  resolverAddr.removePrefix("0x000000000000000000000000")
  result = "0x" & resolverAddr


const pubkey_signature = "0xc8690233" # pubkey(bytes32 node)
proc pubkey*(username: string): string = 
  var userNameHash = namehash(addDomain(username))
  userNameHash.removePrefix("0x")
  let ensResolver = resolver(userNameHash)
  echo ensResolver
  let payload = %* [{
    "to": ensResolver,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{pubkey_signature}{userNameHash}"
  }, "latest"]
  let response = callPrivateRPC("eth_call", payload)
  # TODO: error handling
  var pubkey = response.parseJson["result"].getStr
  if pubkey == "0x" or pubkey == "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000":
    result = ""
  else:
    pubkey.removePrefix("0x")
    result = "0x04" & pubkey