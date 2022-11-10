import json, json_serialization, chronicles, strutils
import ./core, ./utils
import ./response_type

import status_go

export response_type

logScope:
  topics = "rpc-accounts"

const NUMBER_OF_ADDRESSES_TO_GENERATE = 1
const MNEMONIC_PHRASE_LENGTH = 12
const PK_LENGTH_0X_INCLUDED = 132

const GENERATED* = "generated"
const SEED* = "seed"
const KEY* = "key"
const WATCH* = "watch"

proc getAccounts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("accounts_getAccounts")

proc deleteAccount*(address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("accounts_deleteAccount", %* [address])

proc saveAccount*(name, address, path, addressAccountIsDerivedFrom, publicKey, keyUid, accountType, color, emoji: string,
  walletDefaultAccount: bool, chatDefaultAccount: bool): 
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [
    [{
      "name": name,
      "address": address,
      "path": path,
      "derived-from": addressAccountIsDerivedFrom,
      "public-key": publicKey,
      "key-uid": keyUid,
      "type": accountType,
      "color": color,
      "emoji": emoji,
      "wallet": walletDefaultAccount,
      "chat": chatDefaultAccount
    }]
  ]
  return core.callPrivateRPC("accounts_saveAccounts", payload)

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

proc decompressPk*(publicKey: string): RpcResponse[string] =
  discard
  if publicKey.startsWith("0x04") and publicKey.len == PK_LENGTH_0X_INCLUDED:
    # already decompressed
    result.result = publicKey
    return

  var response = status_go.multiformatDeserializePublicKey(publicKey, "f")
  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    let secp256k1Code = "fe701"
    response.removePrefix(secp256k1Code)
    result.result = "0x" & response

proc decompressCommunityKey*(publicKey: string): RpcResponse[string] =

  let response = status_go.decompressPublicKey(publicKey)

  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    result.result = response

proc compressCommunityKey*(publicKey: string): RpcResponse[string] =

  let response = status_go.compressPublicKey(publicKey)

  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    result.result = response

proc compressPk*(publicKey: string): RpcResponse[string] =
  let secp256k1Code = "0xe701"
  let base58btc = "z"
  var multiCodecKey = publicKey
  multiCodecKey.removePrefix("0x")
  multiCodecKey.insert(secp256k1Code)

  let response = status_go.multiformatSerializePublicKey(multiCodecKey, base58btc)

  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    result.result = response

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

proc createAccountFromMnemonicAndDeriveAccountsForPaths*(mnemonic: string, paths: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* {
    "mnemonicPhrase": mnemonic,
    "paths": paths,
    "Bip39Passphrase": ""
  }

  try:
    let response = status_go.createAccountFromMnemonicAndDeriveAccountsForPaths($payload)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "createAccountFromMnemonicAndDeriveAccountsForPaths", exception=e.msg
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

proc saveAccountAndLoginWithKeycard*(chatKey, password: string, account, subaccounts, settings, config: JsonNode): 
  RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.saveAccountAndLoginWithKeycard($account, password, $settings, $config, $subaccounts, chatKey)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "saveAccountAndLogin", exception=e.msg
    raise newException(RpcException, e.msg)

proc convertToKeycardAccount*(keyStoreDir: string, account: JsonNode, settings: JsonNode, password: string, newPassword: string): 
  RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.convertToKeycardAccount(keyStoreDir, $account, $settings, password, newPassword)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "convertToKeycardAccount", exception=e.msg
    raise newException(RpcException, e.msg)

proc login*(name, keyUid: string, kdfIterations: int, hashedPassword, thumbnail, large: string, nodeCfgObj: string):
  RpcResponse[JsonNode]
  {.raises: [Exception].} =
  try:
    var payload = %* {
      "name": name,
      "key-uid": keyUid,
      "identityImage": newJNull(),
      "kdfIterations": kdfIterations,
    }

    if(thumbnail.len>0 and large.len > 0):
      payload["identityImage"] = %* {"thumbnail": thumbnail, "large": large}

    let response = status_go.loginWithConfig($payload, hashedPassword, nodeCfgObj)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "login", exception=e.msg
    raise newException(RpcException, e.msg)

proc loginWithKeycard*(chatKey, password: string, account: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.loginWithKeycard($account, password, chatKey)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "loginWithKeycard", exception=e.msg
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

proc getDerivedAddressList*(password: string, derivedFrom: string, path: string, pageSize: int = 0, pageNumber: int = 6,): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [password, derivedFrom, path, pageSize, pageNumber ]
  result = core.callPrivateRPC("wallet_getDerivedAddressesForPath", payload)

proc getDerivedAddressListForMnemonic*(mnemonic: string, path: string, pageSize: int = 0, pageNumber: int = 6,): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [mnemonic, path, pageSize, pageNumber ]
  result = core.callPrivateRPC("wallet_getDerivedAddressesForMnemonicWithPath", payload)

proc getDerivedAddressForPrivateKey*(privateKey: string,): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [privateKey]
  result = core.callPrivateRPC("wallet_getDerivedAddressForPrivateKey", payload)

proc getDerivedAddressDetails*(address: string,): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address]
  result = core.callPrivateRPC("wallet_getDerivedAddressDetails", payload)

proc verifyPassword*(password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [password]
  return core.callPrivateRPC("accounts_verifyPassword", payload)