import tables, json, strformat, strutils, chronicles

import dto

include  ../../common/json_utils

export dto

const KeypairTypeProfile* = "profile"
const KeypairTypeSeed* = "seed"
const KeypairTypeKey* = "key"

type
  KeypairDto* = ref object of RootObj
    keyUid*: string
    name*: string
    keypairType*: string
    derivedFrom*: string
    lastUsedDerivationIndex*: int
    syncedFrom*: string
    accounts*: seq[WalletAccountDto]

proc toKeypairDto*(jsonObj: JsonNode): KeypairDto =
  result = KeypairDto()
  discard jsonObj.getProp("key-uid", result.keyUid)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("type", result.keypairType)
  discard jsonObj.getProp("derived-from", result.derivedFrom)
  discard jsonObj.getProp("last-used-derivation-index", result.lastUsedDerivationIndex)
  discard jsonObj.getProp("synced-from", result.syncedFrom)

  if result.keypairType != KeypairTypeProfile and
    result.keypairType != KeypairTypeSeed and
    result.keypairType != KeypairTypeKey:
    error "unknown keypair type", kpType=result.keypairType

  var accountsObj: JsonNode
  if(jsonObj.getProp("accounts", accountsObj)):
    for accObj in accountsObj:
      result.accounts.add(toWalletAccountDto(accObj))

proc `$`*(self: KeypairDto): string =
  result = fmt"""KeypairDto[
    keyUid: {self.keyUid},
    name: {self.name},
    type: {self.keypairType},
    derivedFrom: {self.derivedFrom},
    lastUsedDerivationIndex: {self.lastUsedDerivationIndex},
    syncedFrom: {self.syncedFrom},
    accounts: 
  """
  for i in 0 ..< self.accounts.len:
    result &= fmt"""
    [{i}]:({$self.accounts[i]})
    """
  result &= "]"