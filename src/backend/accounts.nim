import json, json_serialization, chronicles, strutils
import ./core, ../app_service/common/utils
import ../app_service/service/wallet_account/dto/account_dto
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

proc getWatchOnlyAccounts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("accounts_getWatchOnlyAccounts")

proc getKeypairs*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("accounts_getKeypairs")

proc getKeypairByKeyUid*(keyUid: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [keyUid]
  return core.callPrivateRPC("accounts_getKeypairByKeyUID", payload)

proc deleteAccount*(address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address]
  return core.callPrivateRPC("accounts_deleteAccount", payload)

proc deleteKeypair*(keyUid: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [keyUid]
  return core.callPrivateRPC("accounts_deleteKeypair", payload)

## Adds a new account and creates a Keystore file if password is provided, otherwise it only creates a new account. Notifies paired devices.
proc addAccount*(password, name, address, path, publicKey, keyUid, accountType, colorId, emoji: string, hideFromTotalBalance: bool):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [
    password,
    {
      "address": address,
      "key-uid": keyUid,
      "wallet": false, #this refers to the default wallet account and it's set at the moment of Status chat account creation, cannot be changed later
      "chat": false, #this refers to Status chat account, set when the Status account is created, cannot be changed later
      "type": accountType,
      "path": path,
      "public-key": publicKey,
      "name": name,
      "emoji": emoji,
      "colorId": colorId,
      "hidden": hideFromTotalBalance
      #"clock" we leave this empty, set on the status-go side
      #"removed" present on the status-go side, used for synchronization, no need to set it here
    }
  ]
  return core.callPrivateRPC("accounts_addAccount", payload)

## Adds a new keypair and creates a Keystore file if password is provided, otherwise it only creates a new keypair. Notifies paired devices.
proc addKeypair*(password, keyUid, keypairName, keypairType, rootWalletMasterKey: string, accounts: seq[WalletAccountDto]):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  var kpJson = %* {
    "key-uid": keyUid,
    "name": keypairName,
    "type": keypairType,
    "derived-from": rootWalletMasterKey,
    "last-used-derivation-index": 0, #when adding new keypair it's always 0
    #"synced-from": "", present on the status-go side, used for synchronization, no need to set it here
    #"clock": 0, we leave this empty, set on the status-go side
    "accounts": []
  }

  for acc in accounts:
    kpJson["accounts"].add(
      %*{
          "address": acc.address,
          "key-uid": keyUid,
          "wallet": false, #this refers to the default wallet account and it's set at the moment of Status chat account creation, cannot be changed later
          "chat": false, #this refers to Status chat account, set when the Status account is created, cannot be changed later
          "type": acc.walletType,
          "path": acc.path,
          "public-key": acc.publicKey,
          "name": acc.name,
          "emoji": acc.emoji,
          "colorId": acc.colorId,
          "hidden": acc.hideFromTotalBalance
          #"clock" we leave this empty, set on the status-go side
          #"removed" present on the status-go side, used for synchronization, no need to set it here
        }
    )

  let payload = %* [password, kpJson]
  return core.callPrivateRPC("accounts_addKeypair", payload)

## Adds a new account without creating a Keystore file and notifies paired devices
proc addAccountWithoutKeystoreFileCreation*(name, address, path, publicKey, keyUid, accountType, colorId, emoji: string, hideFromTotalBalance: bool):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  return addAccount(password = "", name, address, path, publicKey, keyUid, accountType, colorId, emoji, hideFromTotalBalance)

## Updates either regular or keycard account, without interaction to a Keystore file and notifies paired devices
proc updateAccount*(name, address, path: string, publicKey, keyUid, accountType, colorId, emoji: string,
  walletDefaultAccount: bool, chatDefaultAccount: bool, prodPreferredChainIds, testPreferredChainIds: string, hideFromTotalBalance: bool):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [
    {
      "address": address,
      "key-uid": keyUid,
      "wallet": walletDefaultAccount,
      "chat": chatDefaultAccount,
      "type": accountType,
      "path": path,
      "public-key": publicKey,
      "name": name,
      "emoji": emoji,
      "colorId": colorId,
      "prodPreferredChainIds": prodPreferredChainIds,
      "testPreferredChainIds": testPreferredChainIds,
      "hidden": hideFromTotalBalance
      #"clock" we leave this empty, set on the status-go side
      #"removed" present on the status-go side, used for synchronization, no need to set it here
    }
  ]
  return core.callPrivateRPC("accounts_saveAccount", payload)

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

proc getRandomMnemonic*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("accounts_getRandomMnemonic", payload)

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

## Imports a new mnemonic and creates local keystore file.
proc importMnemonic*(mnemonic, password: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [mnemonic, password]
  return core.callPrivateRPC("accounts_importMnemonic", payload)

proc makeSeedPhraseKeypairFullyOperable*(mnemonic, password: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [mnemonic, password]
  return core.callPrivateRPC("accounts_makeSeedPhraseKeypairFullyOperable", payload)

proc makePartiallyOperableAccoutsFullyOperable*(password: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [password]
  return core.callPrivateRPC("accounts_makePartiallyOperableAccoutsFullyOperable", payload)

proc migrateNonProfileKeycardKeypairToApp*(mnemonic: string, password: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [mnemonic, password]
  return core.callPrivateRPC("accounts_migrateNonProfileKeycardKeypairToApp", payload)

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

## Imports a new private key and creates local keystore file.
proc importPrivateKey*(privateKey, password: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [privateKey, password]
  return core.callPrivateRPC("accounts_importPrivateKey", payload)

proc makePrivateKeyKeypairFullyOperable*(privateKey, password: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [privateKey, password]
  return core.callPrivateRPC("accounts_makePrivateKeyKeypairFullyOperable", payload)

proc createAccountFromPrivateKey*(privateKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* {"privateKey": privateKey}
  try:
    let response = status_go.createAccountFromPrivateKey($payload)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "createAccountFromPrivateKey", exception=e.msg
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

proc convertRegularProfileKeypairToKeycard*(account: JsonNode, settings: JsonNode, keycardUid: string, password: string, newPassword: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.convertToKeycardAccount($account, $settings, keycardUid, password, newPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "convertRegularProfileKeypairToKeycard", exception=e.msg
    raise newException(RpcException, e.msg)

proc convertKeycardProfileKeypairToRegular*(mnemonic: string, currPassword: string, newPassword: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.convertToRegularAccount(mnemonic, currPassword, newPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "convertKeycardProfileKeypairToRegular", exception=e.msg
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

proc loginWithKeycard*(chatKey, password: string, account, confNode: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.loginWithKeycard($account, password, chatKey, $confNode)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "loginWithKeycard", exception=e.msg
    raise newException(RpcException, e.msg)

proc verifyAccountPassword*(address: string, hashedPassword: string, keystoreDir: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.verifyAccountPassword(keystoreDir, address, hashedPassword)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "verifyAccountPassword", exception=e.msg
    raise newException(RpcException, e.msg)

proc verifyDatabasePassword*(keyuid: string, hashedPassword: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.verifyDatabasePassword(keyuid, hashedPassword)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "verifyDatabasePassword", exception=e.msg
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

proc getDerivedAddresses*(password: string, derivedFrom: string, paths: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [password, derivedFrom, paths]
  result = core.callPrivateRPC("wallet_getDerivedAddresses", payload)

proc getDerivedAddressesForMnemonic*(mnemonic: string, paths: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [mnemonic, paths]
  result = core.callPrivateRPC("wallet_getDerivedAddressesForMnemonic", payload)

proc getAddressDetails*(chainId: int, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, address]
  result = core.callPrivateRPC("wallet_getAddressDetails", payload)

proc addressExists*(address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address]
  result = core.callPrivateRPC("wallet_addressExists", payload)

proc verifyPassword*(password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [password]
  return core.callPrivateRPC("accounts_verifyPassword", payload)

proc verifyKeystoreFileForAccount*(address, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address, password]
  return core.callPrivateRPC("accounts_verifyKeystoreFileForAccount", payload)

proc getProfileShowcaseForContact*(contactId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [contactId]
  result = callPrivateRPC("getProfileShowcaseForContact".prefix, payload)

proc getProfileShowcasePreferences*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("getProfileShowcasePreferences".prefix, %*[])

proc setProfileShowcasePreferences*(preferences: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("setProfileShowcasePreferences".prefix, preferences)
