import json, json_serialization, chronicles, nimcrypto
import ./core, ./utils
import ./response_type

import status_go

export response_type

logScope:
  topics = "rpc-accounts"

const NUMBER_OF_ADDRESSES_TO_GENERATE = 1
const MNEMONIC_PHRASE_LENGTH = 12

const GENERATED* = "generated"
const SEED* = "seed"
const KEY* = "key"
const WATCH* = "watch"

proc getAccounts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("accounts_getAccounts")

proc deleteAccount*(address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("accounts_deleteAccount", %* [address])

proc updateAccount*(name, address, publicKey, walletType, color, emoji: string) {.raises: [Exception].} =
  discard core.callPrivateRPC("accounts_saveAccounts", %* [
    [{
      "emoji": emoji,
      "color": color,
      "name": name,
      "address": address,
      "public-key": publicKey,
      "type": walletType,
      "path": "m/44'/60'/0'/0/1" # <--- TODO: fix this. Derivation path is not supposed to change
    }]
  ])

proc generateAddresses*(paths: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* {
    "n": NUMBER_OF_ADDRESSES_TO_GENERATE,
    "mnemonicPhraseLength": MNEMONIC_PHRASE_LENGTH,
    "bip39Passphrase": "",
    "paths": paths
  }

  try:
    let response = status_go.multiAccountGenerateAndDeriveAddresses($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "generateAddresses", exception=e.msg
    raise newException(RpcException, e.msg)

proc generateAlias*(publicKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.generateAlias(publicKey)
    result.result = %* response

  except RpcException as e:
    error "error doing rpc request", methodName = "generateAlias", exception=e.msg
    raise newException(RpcException, e.msg)

proc isAlias*(value: string): bool =
  let response = status_go.isAlias(value)
  let r = Json.decode(response, JsonNode)
  return r["result"].getBool()

proc generateIdenticon*(publicKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.identicon(publicKey)
    result.result = %* response

  except RpcException as e:
    error "error doing rpc request", methodName = "generateIdenticon", exception=e.msg
    raise newException(RpcException, e.msg)

proc multiAccountImportMnemonic*(mnemonic: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* {
    "mnemonicPhrase": mnemonic,
    "Bip39Passphrase": ""
  }

  try:
    let response = status_go.multiAccountImportMnemonic($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "multiAccountImportMnemonic", exception=e.msg
    raise newException(RpcException, e.msg)

proc deriveAccounts*(accountId: string, paths: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* {
    "accountID": accountId,
    "paths": paths
  }

  try:
    let response = status_go.multiAccountDeriveAddresses($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "deriveAccounts", exception=e.msg
    raise newException(RpcException, e.msg)

proc openedAccounts*(path: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.openAccounts(path)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "openedAccounts", exception=e.msg
    raise newException(RpcException, e.msg)

proc storeDerivedAccounts*(id, hashedPassword: string, paths: seq[string]):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* {
    "accountID": id,
    "paths": paths,
    "password": hashedPassword
  }

  try:
    let response = status_go.multiAccountStoreDerivedAccounts($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "storeDerivedAccounts", exception=e.msg
    raise newException(RpcException, e.msg)

proc storeAccounts*(id, hashedPassword: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* {
    "accountID": id,
    "password": hashedPassword
  }

  try:
    let response = status_go.multiAccountStoreAccount($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "storeAccounts", exception=e.msg
    raise newException(RpcException, e.msg)

proc saveAccount*(
  address: string,
  name: string,
  password: string,
  color: string,
  accountType: string,
  isADerivedAccount = true,
  walletIndex: int = 0,
  id: string = "",
  publicKey: string = "",
) {.raises: [Exception].} =
  var derivationPath = "m/44'/60'/0'/0/0"
  let hashedPassword = hashPassword(password)

  if (isADerivedAccount):
    let derivationPath = (if accountType == GENERATED: "m/" else: "m/44'/60'/0'/0/") & $walletIndex
    discard storeDerivedAccounts(id, hashedPassword, @[derivationPath])
  elif accountType == KEY:
    discard storeAccounts(id, hashedPassword)

  discard callPrivateRPC("accounts_saveAccounts", %* [
    [{
      "color": color,
      "name": name,
      "address": address,
      "public-key": publicKey,
      "type": accountType,
      "path": derivationPath
    }]
  ])

proc loadAccount*(address: string, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let hashedPassword = hashPassword(password)
  let payload = %* {
    "address": address,
    "password": hashedPassword
  }

  try:
    let response = status_go.multiAccountLoadAccount($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "storeAccounts", exception=e.msg
    raise newException(RpcException, e.msg)

proc addPeer*(peer: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.addPeer(peer)
    result.result = %* response

  except RpcException as e:
    error "error doing rpc request", methodName = "addPeer", exception=e.msg
    raise newException(RpcException, e.msg)

proc saveAccountAndLogin*(hashedPassword: string, account, subaccounts, settings,
  config: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.saveAccountAndLogin($account, hashedPassword,
    $settings, $config, $subaccounts)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "saveAccountAndLogin", exception=e.msg
    raise newException(RpcException, e.msg)

proc login*(name, keyUid, hashedPassword, identicon, thumbnail, large: string, nodeCfgObj: string):
  RpcResponse[JsonNode]
  {.raises: [Exception].} =
  try:
    var payload = %* {
      "name": name,
      "key-uid": keyUid,
      "identityImage": newJNull(),
      "identicon": identicon
    }

    if(thumbnail.len>0 and large.len > 0):
      payload["identityImage"] = %* {"thumbnail": thumbnail, "large": large}

    let response = status_go.loginWithConfig($payload, hashedPassword, nodeCfgObj)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "login", exception=e.msg
    raise newException(RpcException, e.msg)

proc multiAccountImportPrivateKey*(privateKey: string): RpcResponse[JsonNode] =
  let payload = %* {
    "privateKey": privateKey
  }
  try:
    let response = status_go.multiAccountImportPrivateKey($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "multiAccountImportPrivateKey", exception=e.msg
    raise newException(RpcException, e.msg)

proc verifyAccountPassword*(address: string, password: string, keystoreDir: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let hashedPassword = hashPassword(password)
    let response = status_go.verifyAccountPassword(keystoreDir, address, hashedPassword)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "verifyAccountPassword", exception=e.msg
    raise newException(RpcException, e.msg)

proc storeIdentityImage*(keyUID: string, imagePath: string, aX, aY, bX, bY: int):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [keyUID, imagePath, aX, aY, bX, bY]
  result = core.callPrivateRPC("multiaccounts_storeIdentityImage", payload)

proc deleteIdentityImage*(keyUID: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [keyUID]
  result = core.callPrivateRPC("multiaccounts_deleteIdentityImage", payload)

proc setDisplayName*(displayName: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [displayName]
  result = core.callPrivateRPC("setDisplayName".prefix, payload)
