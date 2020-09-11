import strutils
import profile/profile
import nimcrypto
import json
import json_serialization
import tables
import strformat
import libstatus/core
import libstatus/types
import libstatus/utils
import libstatus/wallet
import stew/byteutils
import unicode
import algorithm
import eth/common/eth_types, stew/byteutils, stint
import libstatus/contracts

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

proc userNameOrAlias*(contact: Profile, removeSuffix: bool = false): string =
  if(contact.ensName != "" and contact.ensVerified):
    result = "@" & userName(contact.ensName, removeSuffix)
  else:
    result = contact.alias

proc label*(username:string): string =
  let name = username.toLower()
  var node:array[32, byte] = keccak_256.digest(username).data
  result = "0x" & node.toHex()

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

const registry* = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
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

const owner_signature = "0x02571be3" # owner(bytes32 node)
proc owner*(username: string): string = 
  var userNameHash = namehash(addDomain(username))
  userNameHash.removePrefix("0x")
  let payload = %* [{
    "to": registry,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{owner_signature}{userNameHash}"
  }, "latest"]
  let response = callPrivateRPC("eth_call", payload)
  # TODO: error handling
  let ownerAddr = response.parseJson["result"].getStr;
  if ownerAddr == "0x0000000000000000000000000000000000000000000000000000000000000000":
    return ""
  result = "0x" & ownerAddr.substr(26)

const pubkey_signature = "0xc8690233" # pubkey(bytes32 node)
proc pubkey*(username: string): string = 
  var userNameHash = namehash(addDomain(username))
  userNameHash.removePrefix("0x")
  let ensResolver = resolver(userNameHash)
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

const address_signature = "0x3b3b57de" # addr(bytes32 node)
proc address*(username: string): string = 
  var userNameHash = namehash(addDomain(username))
  userNameHash.removePrefix("0x")
  let ensResolver = resolver(userNameHash)
  let payload = %* [{
    "to": ensResolver,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{address_signature}{userNameHash}"
  }, "latest"]
  let response = callPrivateRPC("eth_call", payload)
  # TODO: error handling
  let address = response.parseJson["result"].getStr;
  if address == "0x0000000000000000000000000000000000000000000000000000000000000000":
    return ""
  result = "0x" & address.substr(26)

proc getPrice*(): Stuint[256] =
  let
    contract = contracts.getContract("ens-usernames")
    payload = %* [{
      "to": $contract.address,
      "data": contract.methods["getPrice"].encodeAbi()
    }, "latest"]
  
  let responseStr = callPrivateRPC("eth_call", payload)
  let response = Json.decode(responseStr, RpcResponse)
  if not response.error.isNil:
    raise newException(RpcException, "Error getting ens username price: " & response.error.message)
  if response.result == "0x":
    raise newException(RpcException, "Error getting ens username price: 0x")
  result = fromHex(Stuint[256], response.result)

proc extractCoordinates*(pubkey: string):tuple[x: string, y:string] =
  result = ("0x" & pubkey[4..67], "0x" & pubkey[68..131])

proc registerUsername*(username:string, address: EthAddress, pubKey: string, password: string): string =
  let
    label = fromHex(FixedBytes[32], label(username))
    coordinates = extractCoordinates(pubkey)
    x = fromHex(FixedBytes[32], coordinates.x)
    y =  fromHex(FixedBytes[32], coordinates.y)
    ensUsernamesContract = contracts.getContract("ens-usernames")
    sntContract = contracts.getContract("snt")
    price = getPrice()
  
  let
    register = Register(label: label, account: address, x: x, y: y)
    registerAbiEncoded = ensUsernamesContract.methods["register"].encodeAbi(register)
    approveAndCallObj = ApproveAndCall[132](to: ensUsernamesContract.address, value: price, data: DynamicBytes[132].fromHex(registerAbiEncoded))
    approveAndCallAbiEncoded = sntContract.methods["approveAndCall"].encodeAbi(approveAndCallObj)
  
  let payload = %* {
      "from": $address,
      "to": $sntContract.address,
      # "gas": 200000, # TODO: obtain gas price?
      "data": approveAndCallAbiEncoded
    }
  let responseStr = sendTransaction($payload, password)
  let response = Json.decode(responseStr, RpcResponse)
  if not response.error.isNil:
    raise newException(RpcException, "Error registering ens-username: " & response.error.message)
  
  trackPendingTransaction(response.result, $address, $sntContract.address, PendingTransactionType.RegisterENS, username & domain)

  result = response.result

proc setPubKey*(username:string, address: EthAddress, pubKey: string, password: string): string =
  var hash = namehash(username)
  hash.removePrefix("0x")

  let
    label = fromHex(FixedBytes[32], "0x" & hash)
    x = fromHex(FixedBytes[32], "0x" & pubkey[4..67])
    y =  fromHex(FixedBytes[32], "0x" & pubkey[68..131])
    resolverContract = contracts.getContract("ens-resolver")

  let
    setPubkey = SetPubkey(label: label, x: x, y: y)
    setPubkeyAbiEncoded = resolverContract.methods["setPubkey"].encodeAbi(setPubkey)
  
  let resolverAddress = resolver(hash)

  let payload = %* {
      "from": $address,
      "to": resolverAddress,
      # "gas": 200000, # TODO: obtain gas price?
      "data": setPubkeyAbiEncoded
  }

  let responseStr = sendTransaction($payload, password)
  let response = Json.decode(responseStr, RpcResponse)
  if not response.error.isNil:
    raise newException(RpcException, "Error setting the pubkey: " & response.error.message)

  trackPendingTransaction(response.result, $address, resolverAddress, PendingTransactionType.SetPubKey, username)

  result = response.result

proc statusRegistrarAddress*():string =
  result = $contracts.getContract("ens-usernames").address
