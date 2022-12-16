{.used.}

import Tables, json

import ../../../common/account_constants

include ../../../common/[json_utils]

type DerivedAccountDetails* = object
  privateKey*: string
  publicKey*: string
  address*: string
  derivationPath*: string

type DerivedAccounts* = object
  whisper*: DerivedAccountDetails
  walletRoot*: DerivedAccountDetails
  defaultWallet*: DerivedAccountDetails
  eip1581*: DerivedAccountDetails
  encryption*: DerivedAccountDetails
  derivations*: Table[string, DerivedAccountDetails] # used to keep all derivations even for custom paths

type GeneratedAccountDto* = object
  id*: string
  privateKey*: string
  publicKey*: string
  address*: string
  keyUid*: string
  mnemonic*: string
  derivedAccounts*: DerivedAccounts
  # The following two are set additionally.
  alias*: string

proc isValid*(self: GeneratedAccountDto): bool =
  result = self.id.len > 0 and self.publicKey.len > 0 and
    self.address.len > 0 and self.keyUid.len > 0

proc toDerivedAccountDetails(jsonObj: JsonNode, derivationPath: string):
  DerivedAccountDetails =
  # Mapping this DTO is not strightforward since only keys are used for id. We
  # handle it a bit different.
  result = DerivedAccountDetails()
  result.derivationPath = derivationPath
  discard jsonObj.getProp("privateKey", result.privateKey)
  discard jsonObj.getProp("publicKey", result.publicKey)
  discard jsonObj.getProp("address", result.address)

proc toDerivedAccounts*(jsonObj: JsonNode): DerivedAccounts =
  result = DerivedAccounts()
  for derivationPath, derivedObj in jsonObj:
    result.derivations[derivationPath] = toDerivedAccountDetails(derivedObj, derivationPath)
    if(derivationPath == PATH_WHISPER):
      result.whisper = toDerivedAccountDetails(derivedObj, derivationPath)
    elif(derivationPath == PATH_WALLET_ROOT):
      result.walletRoot = toDerivedAccountDetails(derivedObj, derivationPath)
    elif(derivationPath == PATH_DEFAULT_WALLET):
      result.defaultWallet = toDerivedAccountDetails(derivedObj, derivationPath)
    elif(derivationPath == PATH_EIP_1581):
      result.eip1581 = toDerivedAccountDetails(derivedObj, derivationPath)
    elif(derivationPath == PATH_ENCRYPTION):
      result.encryption = toDerivedAccountDetails(derivedObj, derivationPath)

proc toGeneratedAccountDto*(jsonObj: JsonNode): GeneratedAccountDto =
  result = GeneratedAccountDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("privateKey", result.privateKey)
  discard jsonObj.getProp("publicKey", result.publicKey)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("keyUid", result.keyUid)
  discard jsonObj.getProp("mnemonic", result.mnemonic)

  var derivationsObj: JsonNode
  if(jsonObj.getProp("derived", derivationsObj)):
    result.derivedAccounts = toDerivedAccounts(derivationsObj)
