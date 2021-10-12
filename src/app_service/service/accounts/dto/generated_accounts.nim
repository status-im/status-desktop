{.used.}

import json

import ../../../common/account_constants

include ../../../common/[json_utils]

type DerivedAccountDetails* = object
  publicKey*: string
  address*: string
  derivationPath*: string

type DerivedAccounts* = object
  whisper*: DerivedAccountDetails
  walletRoot*: DerivedAccountDetails
  defaultWallet*: DerivedAccountDetails
  eip1581*: DerivedAccountDetails

type GeneratedAccountDto* = ref object
  id*: string 
  publicKey*: string
  address*: string
  keyUid*: string
  mnemonic*: string
  derivedAccounts*: DerivedAccounts
  # The following two are set additionally.
  alias*: string
  identicon*: string

proc toDerivedAccountDetails(jsonObj: JsonNode, derivationPath: string): 
  DerivedAccountDetails =
  # Mapping this DTO is not strightforward since only keys are used for id. We 
  # handle it a bit different.
  result = DerivedAccountDetails()
  result.derivationPath = derivationPath
  discard jsonObj.getProp("publicKey", result.publicKey)
  discard jsonObj.getProp("address", result.address)

proc toDerivedAccounts*(jsonObj: JsonNode): DerivedAccounts =
  result = DerivedAccounts()
  for derivationPath, derivedObj in jsonObj:
    if(derivationPath == PATH_WHISPER):
      result.whisper = toDerivedAccountDetails(derivedObj, derivationPath)
    elif(derivationPath == PATH_WALLET_ROOT):
      result.walletRoot = toDerivedAccountDetails(derivedObj, derivationPath)
    elif(derivationPath == PATH_DEFAULT_WALLET):
      result.defaultWallet = toDerivedAccountDetails(derivedObj, derivationPath)
    elif(derivationPath == PATH_EIP_1581):
      result.eip1581 = toDerivedAccountDetails(derivedObj, derivationPath)

proc toGeneratedAccountDto*(jsonObj: JsonNode): GeneratedAccountDto =
  result = GeneratedAccountDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("publicKey", result.publicKey)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("keyUid", result.keyUid)
  discard jsonObj.getProp("mnemonic", result.mnemonic)
  
  var derivationsObj: JsonNode
  if(jsonObj.getProp("derived", derivationsObj)):
    result.derivedAccounts = toDerivedAccounts(derivationsObj)