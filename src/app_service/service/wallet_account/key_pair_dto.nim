import json

include  ../../common/json_utils

type KeyPairDto* = object
  keycardUid*: string
  keypairName*: string
  keycardLocked*: bool  
  accountsAddresses*: seq[string]
  keyUid*: string

proc toKeyPairDto*(jsonObj: JsonNode): KeyPairDto =
  result = KeyPairDto()
  discard jsonObj.getProp("keycard-uid", result.keycardUid)
  discard jsonObj.getProp("keypair-name", result.keypairName)
  discard jsonObj.getProp("keycard-locked", result.keycardLocked)
  discard jsonObj.getProp("key-uid", result.keyUid)
  
  var jArr: JsonNode
  if(jsonObj.getProp("accounts-addresses", jArr) and jArr.kind == JArray):
    for addrObj in jArr:
      result.accountsAddresses.add(addrObj.getStr)
