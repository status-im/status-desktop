import json

include  ../../common/json_utils

const ParamKeycardUid = "keycard-uid"
const ParamKeycardName = "keycard-name"
const ParamKeycardLocked = "keycard-locked"
const ParamKeyUid = "key-uid"
const ParamAccountAddresses = "accounts-addresses"
const ParamAction = "action"
const ParamOldKeycardUid = "old-keycard-uid"
const ParamKeycard = "keycard"

const KeycardActionKeycardAdded* = "KEYCARD_ADDED"
const KeycardActionAccountsAdded* = "ACCOUNTS_ADDED"
const KeycardActionKeycardDeleted* = "KEYCARD_DELETED"
const KeycardActionAccountsRemoved* = "ACCOUNTS_REMOVED"
const KeycardActionLocked* = "LOCKED"
const KeycardActionUnlocked* = "UNLOCKED"
const KeycardActionUidUpdated* = "UID_UPDATED"
const KeycardActionNameChanged* = "NAME_CHANGED"

type KeyPairDto* = object
  keycardUid*: string
  keycardName*: string
  keycardLocked*: bool  
  accountsAddresses*: seq[string]
  keyUid*: string

type KeycardActionDto* = object
  action*: string
  oldKeycardUid*: string
  keycard*: KeyPairDto

proc toKeyPairDto*(jsonObj: JsonNode): KeyPairDto =
  result = KeyPairDto()
  discard jsonObj.getProp(ParamKeycardUid, result.keycardUid)
  discard jsonObj.getProp(ParamKeycardName, result.keycardName)
  discard jsonObj.getProp(ParamKeycardLocked, result.keycardLocked)
  discard jsonObj.getProp(ParamKeyUid, result.keyUid)
  
  var jArr: JsonNode
  if(jsonObj.getProp(ParamAccountAddresses, jArr) and jArr.kind == JArray):
    for addrObj in jArr:
      result.accountsAddresses.add(addrObj.getStr)

proc toKeycardActionDto*(jsonObj: JsonNode): KeycardActionDto =
  result = KeycardActionDto()
  discard jsonObj.getProp(ParamAction, result.action)
  discard jsonObj.getProp(ParamOldKeycardUid, result.oldKeycardUid)
  
  var keycardObj: JsonNode
  if(jsonObj.getProp("keycard", keycardObj)):
    result.keycard = toKeyPairDto(keycardObj)

proc toJsonNode*(self: KeyPairDto): JsonNode =
  result = %* {
    ParamKeycardUid: self.keycardUid,
    ParamKeycardName: self.keycardName,
    ParamKeycardLocked: self.keycardLocked,
    ParamKeyUid: self.keyUid,
    ParamAccountAddresses: self.accountsAddresses
  }