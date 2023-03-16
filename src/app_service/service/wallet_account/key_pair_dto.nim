import json

include  ../../common/json_utils

const KeycardUid = "keycard-uid"
const KeycardName = "keycard-name"
const KeycardLocked = "keycard-locked"
const KeyUid = "key-uid"
const AccountAddresses = "accounts-addresses"


type KeyPairDto* = object
  keycardUid*: string
  keycardName*: string
  keycardLocked*: bool  
  accountsAddresses*: seq[string]
  keyUid*: string

proc toKeyPairDto*(jsonObj: JsonNode): KeyPairDto =
  result = KeyPairDto()
  discard jsonObj.getProp(KeycardUid, result.keycardUid)
  discard jsonObj.getProp(KeycardName, result.keycardName)
  discard jsonObj.getProp(KeycardLocked, result.keycardLocked)
  discard jsonObj.getProp(KeyUid, result.keyUid)
  
  var jArr: JsonNode
  if(jsonObj.getProp(AccountAddresses, jArr) and jArr.kind == JArray):
    for addrObj in jArr:
      result.accountsAddresses.add(addrObj.getStr)

proc toJsonNode*(self: KeyPairDto): JsonNode =
  result = %* {
    KeycardUid: self.keycardUid,
    KeycardName: self.keycardName,
    KeycardLocked: self.keycardLocked,
    KeyUid: self.keyUid,
    AccountAddresses: self.accountsAddresses
  }